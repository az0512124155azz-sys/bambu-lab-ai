"""
Bambu Monitor - background launcher.

Runs the API server in a background thread and shows the dashboard in
its own native app window (via pywebview) - not a browser tab. A tray
icon lets you quit even if the window is closed/minimized.
"""

import threading
import time

import pystray
import uvicorn
import webview
from PIL import Image, ImageDraw

from pathlib import Path

APP_DIR = Path(__file__).parent
PORT = 8000
URL = f"http://localhost:{PORT}"

_tray_icon = None


def make_icon_image():
    img = Image.new("RGB", (64, 64), "#1d9e75")
    draw = ImageDraw.Draw(img)
    draw.ellipse((14, 14, 50, 50), fill="white")
    return img


def run_server():
    import os
    os.chdir(APP_DIR)
    uvicorn.run("api:app", host="127.0.0.1", port=PORT, log_level="warning")


def quit_app(icon=None, item=None):
    if _tray_icon:
        _tray_icon.stop()
    import os
    os._exit(0)


def run_tray():
    global _tray_icon
    menu = pystray.Menu(pystray.MenuItem("Quit", quit_app))
    _tray_icon = pystray.Icon("bambu_monitor", make_icon_image(), "Bambu AI Monitor", menu)
    _tray_icon.run()


def wait_for_server():
    import urllib.request
    for _ in range(60):
        try:
            urllib.request.urlopen(URL, timeout=1)
            return
        except Exception:
            time.sleep(0.5)


def main():
    threading.Thread(target=run_server, daemon=True).start()
    threading.Thread(target=run_tray, daemon=True).start()

    wait_for_server()

    window = webview.create_window(
        "Bambu AI Monitor",
        URL,
        width=1100,
        height=760,
        min_size=(700, 500),
    )
    # Closing the window exits the whole app (server + tray) - simplest,
    # least surprising behavior for a single-window app.
    window.events.closed += lambda: quit_app()

    # private_mode=True + a storage path unique to THIS app stops WebView2
    # from sharing cache/history with any other pywebview-based app on the
    # machine (Edge WebView2 uses a shared default profile folder unless
    # told otherwise, which caused stale content from a different local
    # app to render here).
    import tempfile
    storage_dir = Path(tempfile.gettempdir()) / "bambu_ai_monitor_webview_data"
    webview.start(private_mode=True, storage_path=str(storage_dir))


if __name__ == "__main__":
    main()
