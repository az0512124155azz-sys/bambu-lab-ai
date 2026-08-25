"""
Bambu Lab AI Print Monitor
---------------------------
Connects to a Bambu Lab printer over local MQTT (recommended — no cloud
account needed if "LAN Mode" is enabled on the printer), pulls camera
snapshots, sends them to a vision model via OpenRouter for failure
detection, and pushes alerts with the image + confidence + summary.

Run:
    pip install -r requirements.txt
    python monitor.py

Config is read from config.yaml (see config.example.yaml).
"""

import base64
import io
import json
import ssl
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path

import cv2
import requests
import yaml
import paho.mqtt.client as mqtt

CONFIG_PATH = Path(__file__).parent / "config.yaml"

# ---------------------------------------------------------------------------
# The single most important lever for false-negative rate: this prompt.
# ---------------------------------------------------------------------------
VISION_SYSTEM_PROMPT = """You are a zero-tolerance 3D print failure detector \
watching a live snapshot from a Bambu Lab FDM printer's onboard camera.

Your ONLY job is to catch failures as early as possible. A missed failure \
wastes filament, time, and can damage the printer — a false alarm costs \
nothing but a moment of the operator's attention. Given this asymmetry, you \
MUST operate with extreme sensitivity: if there is even a 1% chance \
something is wrong, you flag it as a potential issue rather than staying \
silent.

Look specifically for these failure signatures:
- Spaghetti / detached print (filament strands loose in the air or piled up, \
part no longer attached to the bed)
- Layer shifting (any horizontal misalignment between layers)
- First-layer adhesion failure (corners lifting, part sliding, gaps under \
the first layer, elephant's foot gone wrong)
- Nozzle blobs / clogs (large blob of filament stuck to the nozzle or \
dragging across the print)
- Stringing / excessive oozing beyond normal cosmetic stringing
- Warping (corners curling upward)
- Under-extrusion / missing layers / visible gaps in infill or walls
- Anything else that looks abnormal compared to a healthy, in-progress print

You must ALWAYS respond with strict JSON only, no other text, in this exact \
schema:

{
  "failure_detected": boolean,      // true if ANY suspicion exists, even 1%
  "confidence": number,             // 0-100, your estimated confidence there IS a problem
  "issue_type": string,             // one of: "spaghetti", "layer_shift", "adhesion_failure", "nozzle_blob", "stringing", "warping", "under_extrusion", "other", "none"
  "summary": string,                // one concise sentence describing what you see
  "reasoning": string                // brief note on what visual evidence drove the score
}

Calibration: because false negatives are far more costly than false \
positives, set failure_detected=true whenever confidence >= 5. Do not wait \
for certainty. A blurry or ambiguous frame that COULD show a problem should \
still be flagged with a note in reasoning that the frame was ambiguous — \
never silently pass on an unclear frame.
"""


@dataclass
class AppConfig:
    openrouter_api_key: str
    vision_model: str
    scan_interval_seconds: int
    printer_ip: str
    printer_access_code: str
    printer_serial: str
    notify_backend: str  # "ntfy" | "pushover" | "telegram"
    notify_config: dict = field(default_factory=dict)
    confidence_alert_threshold: int = 5  # matches prompt calibration


def load_config() -> AppConfig:
    with open(CONFIG_PATH) as f:
        raw = yaml.safe_load(f)
    return AppConfig(**raw)


# ---------------------------------------------------------------------------
# Camera snapshot capture (Bambu printers expose an RTSP-ish/TCP JPEG stream
# on port 6000 when LAN mode + "Access Code" is enabled on the printer)
# ---------------------------------------------------------------------------
class BambuCameraClient:
    def __init__(self, printer_ip: str, access_code: str):
        self.printer_ip = printer_ip
        self.access_code = access_code
        self._cap = None

    def connect(self):
        # Bambu X1/P1 series serve an authenticated MJPEG-over-TCP stream.
        # OpenCV's ffmpeg backend can read it directly with the right URL.
        url = f"rtsps://bblp:{self.access_code}@{self.printer_ip}:322/streaming/live/1"
        self._cap = cv2.VideoCapture(url, cv2.CAP_FFMPEG)
        if not self._cap.isOpened():
            raise ConnectionError(
                f"Could not open camera stream at {self.printer_ip}. "
                "Confirm LAN Mode + Developer/Access Code are enabled on the printer."
            )

    def get_snapshot_jpeg_bytes(self) -> bytes:
        if self._cap is None:
            self.connect()
        ok, frame = self._cap.read()
        if not ok:
            raise IOError("Failed to read frame from camera stream")
        ok, buf = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
        if not ok:
            raise IOError("Failed to encode frame as JPEG")
        return buf.tobytes()


# ---------------------------------------------------------------------------
# Printer control + telemetry via local MQTT (Bambu's LAN-mode MQTT broker
# runs on the printer itself at port 8883, TLS, user "bblp")
# ---------------------------------------------------------------------------
class BambuMQTTClient:
    def __init__(self, printer_ip: str, access_code: str, serial: str):
        self.printer_ip = printer_ip
        self.access_code = access_code
        self.serial = serial
        self.client = mqtt.Client()
        self.client.username_pw_set("bblp", access_code)
        self.client.tls_set(cert_reqs=ssl.CERT_NONE)
        self.client.tls_insecure_set(True)
        self.connected = threading.Event()
        self.client.on_connect = self._on_connect

    def _on_connect(self, client, userdata, flags, rc):
        self.connected.set()

    def connect(self):
        self.client.connect(self.printer_ip, 8883, keepalive=30)
        self.client.loop_start()
        self.connected.wait(timeout=10)

    def _publish_command(self, payload: dict):
        topic = f"device/{self.serial}/request"
        self.client.publish(topic, json.dumps(payload))

    def pause_print(self):
        self._publish_command({"print": {"command": "pause", "sequence_id": "0"}})

    def stop_print(self):
        self._publish_command({"print": {"command": "stop", "sequence_id": "0"}})

    def resume_print(self):
        self._publish_command({"print": {"command": "resume", "sequence_id": "0"}})


# ---------------------------------------------------------------------------
# OpenRouter vision call
# ---------------------------------------------------------------------------
def analyze_frame(cfg: AppConfig, jpeg_bytes: bytes) -> dict:
    b64 = base64.b64encode(jpeg_bytes).decode("utf-8")
    resp = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {cfg.openrouter_api_key}",
            "Content-Type": "application/json",
        },
        json={
            "model": cfg.vision_model,  # e.g. "google/gemini-2.0-flash-001" or "anthropic/claude-3.5-sonnet"
            "messages": [
                {"role": "system", "content": VISION_SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Analyze this print snapshot now. Respond with JSON only.",
                        },
                        {
                            "type": "image_url",
                            "image_url": {"url": f"data:image/jpeg;base64,{b64}"},
                        },
                    ],
                },
            ],
            "temperature": 0,
            "response_format": {"type": "json_object"},
        },
        timeout=30,
    )
    resp.raise_for_status()
    content = resp.json()["choices"][0]["message"]["content"]
    return json.loads(content)


# ---------------------------------------------------------------------------
# Notifications — default backend is ntfy.sh (free, no account needed)
# ---------------------------------------------------------------------------
def send_alert(cfg: AppConfig, jpeg_bytes: bytes, analysis: dict):
    if cfg.notify_backend == "ntfy":
        topic = cfg.notify_config["topic"]
        requests.put(
            f"https://ntfy.sh/{topic}",
            data=jpeg_bytes,
            headers={
                "Title": f"Print issue: {analysis['issue_type']} ({analysis['confidence']}%)",
                "Priority": "urgent" if analysis["confidence"] >= 40 else "high",
                "Tags": "warning,camera",
                "Filename": "snapshot.jpg",
                "Message": analysis["summary"],
            },
        )
    elif cfg.notify_backend == "pushover":
        requests.post(
            "https://api.pushover.net/1/messages.json",
            data={
                "token": cfg.notify_config["app_token"],
                "user": cfg.notify_config["user_key"],
                "title": f"Print issue: {analysis['issue_type']}",
                "message": f"{analysis['summary']} (confidence {analysis['confidence']}%)",
                "priority": 1,
            },
            files={"attachment": ("snapshot.jpg", jpeg_bytes, "image/jpeg")},
        )
    elif cfg.notify_backend == "telegram":
        bot_token = cfg.notify_config["bot_token"]
        chat_id = cfg.notify_config["chat_id"]
        caption = f"⚠️ {analysis['issue_type']} ({analysis['confidence']}%)\n{analysis['summary']}"
        requests.post(
            f"https://api.telegram.org/bot{bot_token}/sendPhoto",
            data={"chat_id": chat_id, "caption": caption},
            files={"photo": ("snapshot.jpg", jpeg_bytes, "image/jpeg")},
        )
    else:
        raise ValueError(f"Unknown notify_backend: {cfg.notify_backend}")


# ---------------------------------------------------------------------------
# Main monitor loop
# ---------------------------------------------------------------------------
class PrintMonitor:
    def __init__(self, cfg: AppConfig):
        self.cfg = cfg
        self.camera = BambuCameraClient(cfg.printer_ip, cfg.printer_access_code)
        self.mqtt = BambuMQTTClient(cfg.printer_ip, cfg.printer_access_code, cfg.printer_serial)
        self.running = False
        self.last_analysis = None
        self.last_snapshot_path = Path("last_snapshot.jpg")

    def start(self):
        self.mqtt.connect()
        self.camera.connect()
        self.running = True
        threading.Thread(target=self._loop, daemon=True).start()

    def stop(self):
        self.running = False

    def _loop(self):
        while self.running:
            try:
                jpeg = self.camera.get_snapshot_jpeg_bytes()
                self.last_snapshot_path.write_bytes(jpeg)
                analysis = analyze_frame(self.cfg, jpeg)
                self.last_analysis = analysis
                print(f"[scan] {analysis}")
                if analysis.get("failure_detected") and analysis.get("confidence", 0) >= self.cfg.confidence_alert_threshold:
                    send_alert(self.cfg, jpeg, analysis)
            except Exception as e:
                print(f"[error] {e}")
            time.sleep(self.cfg.scan_interval_seconds)

    # Emergency controls, called from UI / API
    def pause(self):
        self.mqtt.pause_print()

    def cancel(self):
        self.mqtt.stop_print()


if __name__ == "__main__":
    config = load_config()
    monitor = PrintMonitor(config)
    monitor.start()
    print("Monitoring started. Ctrl+C to stop.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        monitor.stop()
