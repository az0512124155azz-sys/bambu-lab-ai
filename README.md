# Bambu Lab AI Monitor — Boilerplate

## What's here
- `backend/monitor.py` — core loop: MQTT control + camera snapshot + OpenRouter vision analysis + alerting
- `backend/api.py` — FastAPI HTTP layer (settings, status, snapshot, pause/cancel) for a UI to call
- `backend/config.example.yaml` — copy to `config.yaml` and fill in your printer + API details
- `scripts/install_windows.bat` / `run_windows.bat` — one-click setup + run on Windows
- `scripts/build_android_apk.sh` — builds an installable APK (thin WebView client pointing at your backend)
- `android/` — minimal Android app project

## Setup
1. On the printer: enable **LAN Mode** (Settings > Network) and note the **Access Code** and **Serial** (Settings > Device).
2. `cd backend && cp config.example.yaml config.yaml` and fill in: printer IP/access code/serial, your OpenRouter API key, and a notification backend (ntfy is zero-setup: just pick a topic name and install the ntfy app).
3. Windows: run `scripts\install_windows.bat` then `scripts\run_windows.bat`.
   Mac/Linux: `pip install -r backend/requirements.txt && cd backend && uvicorn api:app --host 0.0.0.0 --port 8000`.
4. Edit `android/app/src/main/java/.../MainActivity.kt` → set `SERVER_URL` to your PC's LAN IP + `:8000`, then run `scripts/build_android_apk.sh` (or open `android/` in Android Studio and hit Run) to get an installable APK.

## Note on the target GitHub repo
I can't push directly to your `bambu-lab-ai` repo — I don't have your GitHub credentials/token in this environment. Easiest path:

```bash
git clone https://github.com/az0512124155azz-sys/bambu-lab-ai.git
cp -r bambu-lab-ai-boilerplate/* bambu-lab-ai/
cd bambu-lab-ai
git add . && git commit -m "Add AI monitor boilerplate + Windows/Android installers" && git push
```

(The BambuStudio repo you linked is Bambu's slicer app, not needed for this — this project talks to the printer's local MQTT/camera interfaces directly, same ones BambuStudio itself uses.)
