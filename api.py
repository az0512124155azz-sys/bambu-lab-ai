"""
FastAPI wrapper exposing the monitor over HTTP: settings, live snapshot +
status, pause/cancel controls, and the dashboard UI itself at "/".

Run: uvicorn api:app --host 127.0.0.1 --port 8000
"""

from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse, HTMLResponse, JSONResponse
from pydantic import BaseModel

from monitor import AppConfig, PrintMonitor, load_config

app = FastAPI(title="Bambu Lab AI Monitor")
_monitor: PrintMonitor | None = None
STATIC_DIR = Path(__file__).parent / "static"


@app.on_event("startup")
def auto_start_from_config():
    """If config.yaml is already filled in, start monitoring immediately
    on launch instead of waiting for a POST /settings call the UI never
    makes."""
    global _monitor
    try:
        cfg = load_config()
        if cfg.printer_ip and cfg.openrouter_api_key:
            _monitor = PrintMonitor(cfg)
            _monitor.start()
    except Exception as e:
        print(f"[startup] Not auto-starting monitor yet: {e}")


class Settings(BaseModel):
    openrouter_api_key: str
    vision_model: str = "google/gemini-2.0-flash-001"
    scan_interval_seconds: int = 15
    printer_ip: str
    printer_access_code: str
    printer_serial: str
    notify_backend: str = "ntfy"
    notify_config: dict = {}


@app.get("/", response_class=HTMLResponse)
def dashboard():
    return (STATIC_DIR / "index.html").read_text(encoding="utf-8")


@app.post("/settings")
def save_settings(s: Settings):
    global _monitor
    cfg = AppConfig(**s.dict())
    _monitor = PrintMonitor(cfg)
    _monitor.start()
    return {"status": "started"}


@app.get("/status")
@app.get("/printer/status")
def status():
    if not _monitor:
        return {"stage": "not configured - edit config.yaml"}
    telemetry = _monitor.mqtt.latest if hasattr(_monitor.mqtt, "latest") else {}
    return {**telemetry, "last_analysis": _monitor.last_analysis}


@app.get("/snapshot")
def snapshot():
    if not _monitor or not _monitor.last_snapshot_path.exists():
        return JSONResponse({"error": "no snapshot yet"}, status_code=404)
    return FileResponse(_monitor.last_snapshot_path)


@app.post("/control/pause")
@app.post("/printer/pause")
def pause():
    if not _monitor:
        return JSONResponse({"error": "not configured"}, status_code=400)
    _monitor.pause()
    return {"status": "paused"}


@app.post("/control/cancel")
@app.post("/printer/cancel")
def cancel():
    if not _monitor:
        return JSONResponse({"error": "not configured"}, status_code=400)
    _monitor.cancel()
    return {"status": "cancelled"}
