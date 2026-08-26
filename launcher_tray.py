"""
Bambu Monitor - background launcher.

Runs the API server in a background thread, opens the dashboard in the
default browser once, and shows a system tray icon with Open / Quit —
so this behaves like a normal installed Windows app instead of a
terminal window you have to babysit.
"""

import threading
import time
import webbrowser
from pathlib import Path

import pystray
import uvicorn
from PIL import Image, ImageDraw

APP_DIR = Path(__file__).parent
PORT = 8000
URL = f"http://localhost:{PORT}"


def make_icon_image():
    img = Image.new("RGB", (64, 64), "#1d9e75")
    draw = ImageDraw.Draw(img)
    draw.ellipse((14, 14, 50, 50), fill="white")
    return img


def run_server():
    import os
    os.chdir(APP_DIR)
    uvicorn.run("api:app", host="0.0.0.0", port=PORT, log_level="warning")


def open_dashboard(icon=None, item=None):
    webbrowser.open(URL)


def quit_app(icon, item):
    icon.stop()
    import os
    os._exit(0)


def main():
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()

    time.sleep(1.5)
    open_dashboard()

    menu = pystray.Menu(
        pystray.MenuItem("Open dashboard", open_dashboard, default=True),
        pystray.MenuItem("Quit", quit_app),
    )
    tray_icon = pystray.Icon("bambu_monitor", make_icon_image(), "Bambu AI Monitor", menu)
    tray_icon.run()


if __name__ == "__main__":
    main()
