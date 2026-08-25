"""
FastAPI wrapper exposing the monitor over HTTP so a phone/web/desktop UI
can hit it: settings, live snapshot + status, pause/cancel controls.

Run: uvicorn api:app --host 0.0.0.0 --port 8000
"""

from fastapi import FastAPI
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

from monitor import AppConfig, PrintMonitor, load_config

app = FastAPI(title="Bambu Lab AI Monitor")
_monitor: PrintMonitor | None = None


class Settings(BaseModel):
    openrouter_api_key: str
    vision_model: str = "google/gemini-2.0-flash-001"
    scan_interval_seconds: int = 15
    printer_ip: str
    printer_access_code: str
    printer_serial: str
    notify_backend: str = "ntfy"
    notify_config: dict = {}


@app.post("/settings")
def save_settings(s: Settings):
    global _monitor
    cfg = AppConfig(**s.dict())
    _monitor = PrintMonitor(cfg)
    _monitor.start()
    return {"status": "started"}


@app.get("/status")
def status():
    if not _monitor:
        return JSONResponse({"error": "not started"}, status_code=400)
    return {"last_analysis": _monitor.last_analysis}


@app.get("/snapshot")
def snapshot():
    if not _monitor or not _monitor.last_snapshot_path.exists():
        return JSONResponse({"error": "no snapshot yet"}, status_code=404)
    return FileResponse(_monitor.last_snapshot_path)


@app.post("/control/pause")
def pause():
    _monitor.pause()
    return {"status": "paused"}


@app.post("/control/cancel")
def cancel():
    _monitor.cancel()
    return {"status": "cancelled"}
