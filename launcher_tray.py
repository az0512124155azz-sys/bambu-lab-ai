"""
Bambu Monitor - background launcher.

Runs the API server in a background thread and shows the dashboard in
its own native app window (via pywebview) - not a browser tab. A tray
icon lets you quit even if the window is closed/minimized.
"""

import sys
import threading
import time
import traceback
import tempfile
from pathlib import Path

import pystray
import uvicorn
import webview
from PIL import Image, ImageDraw

APP_DIR = Path(__file__).parent
PORT = 8000
URL = f"http://127.0.0.1:{PORT}"

_tray_icon = None
_window_ready = False


def make_icon_image():
    img = Image.new("RGB", (64, 64), "#1d9e75")
    draw = ImageDraw.Draw(img)
    draw.ellipse((14, 14, 50, 50), fill="white")
    return img


def run_server():
    import os
    os.chdir(APP_DIR)
    uvicorn.run("api:app", host="127.0.0.1", port=PORT, log_level="info")


def quit_app(icon=None, item=None):
    if _tray_icon:
        _tray_icon.stop()
    import os
    os._exit(0)


def on_window_closed():
    # Only treat this as "user closed the window" if it actually finished
    # loading first - otherwise a failed/instant window creation would
    # kill the whole app before we can see why.
    if _window_ready:
        quit_app()
    else:
        print("[launcher] Window closed before it finished loading - "
              "this usually means the WebView2 runtime is missing or "
              "failed to start. Not exiting so you can read this message.")


def on_window_loaded():
    global _window_ready
    _window_ready = True
    print("[launcher] Window loaded successfully.")


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
            print("[launcher] Server is up.")
            return True
        except Exception:
            time.sleep(0.5)
    print("[launcher] WARNING: server did not respond after 30s - "
          "opening the window anyway, but it may be blank.")
    return False


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
    window.events.closed += on_window_closed
    window.events.loaded += on_window_loaded

    try:
        # debug=True opens DevTools (right-click > Inspect) if something
        # still renders wrong, and prints webview backend errors to this
        # console instead of failing silently.
        webview.start(debug=True)
    except Exception:
        print("[launcher] webview.start() crashed:")
        traceback.print_exc()
        input("Press Enter to exit...")
        sys.exit(1)


if __name__ == "__main__":
    main()
