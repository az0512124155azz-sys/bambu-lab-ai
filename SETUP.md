# Bambu Lab AI Monitor - Setup Guide

## Windows Setup

### 1. Install Python
- Download Python 3.10 or later from https://www.python.org/downloads/
- **Important:** Check "Add Python to PATH" during installation
- Verify: Open Command Prompt and run `python --version`

### 2. Run Installation
```batch
install_windows.bat
```

This will:
- Create a Python virtual environment
- Install all dependencies
- Create config.yaml from config.example.yaml

### 3. Configure
Edit `config.yaml` with your printer details:
- Printer IP address
- Access Code
- Serial Number
- OpenRouter API key

### 4. Start the Monitor
```batch
run_windows.bat
```

The API will start on http://localhost:8000

---

## Android APK Build

### Prerequisites
1. **Android Studio** - Download from https://developer.android.com/studio
2. **Android SDK** - Installed via Android Studio
3. **JDK 17+** - Usually installed with Android Studio

### Setup Android SDK
1. Open Android Studio
2. Go to File > Open
3. Select the `android` folder from this project
4. Wait for Gradle to sync and download SDK components
5. Once complete, close Android Studio

### Build APK

**On Windows (Git Bash or Command Prompt):**
```bash
bash build_android_apk.sh
```

**On Mac/Linux:**
```bash
./build_android_apk.sh
```

**Or use Android Studio:**
1. Open the `android` folder in Android Studio
2. Click Build > Build APK(s)
3. APK will be at: `android/app/build/outputs/apk/debug/app-debug.apk`

### Configure Server URL
Before building, edit `android/app/src/main/java/com/magic3d/bambumonitor/MainActivity.kt`

Find this line:
```kotlin
private val SERVER_URL = "http://localhost:8000"
```

Replace with your PC's IP address:
```kotlin
private val SERVER_URL = "http://192.168.1.100:8000"
```

### Install APK on Phone
1. Connect Android phone via USB
2. Enable Developer Mode: Settings > About > tap Build Number 7 times
3. Enable USB Debugging: Settings > Developer Options > USB Debugging
4. Run:
   ```bash
   adb install android/app/build/outputs/apk/debug/app-debug.apk
   ```

Or manually:
1. Copy app-debug.apk to your phone
2. Open file manager and tap the APK
3. Install (allow unknown sources if prompted)

---

## Troubleshooting

### Windows

**"Python was not found"**
- Install Python from https://www.python.org/downloads/
- Make sure to check "Add Python to PATH"
- Restart Command Prompt after installation

**"api.py not found"**
- Make sure you're running install_windows.bat from the project root

**"config.yaml not found"**
- Run install_windows.bat first
- Edit the generated config.yaml file

### Android

**"gradlew not found"**
- Open the `android` folder in Android Studio
- Let it sync and download Gradle components
- Then try building again

**"Android SDK not found"**
- Install Android Studio
- Set ANDROID_HOME environment variable or let Android Studio handle it

**"Build failed"**
- Update Android Studio
- Check that you have Android API 34 and Build Tools 34.0.0 installed
- In Android Studio: Preferences > System Settings > Android SDK

---

## Next Steps

1. Make sure your Bambu printer is on the same network
2. Enable LAN Mode on the printer (Settings > Network)
3. Note the Access Code and Serial Number
4. Fill in config.yaml with these details
5. Start the monitor with run_windows.bat
6. Access the web interface at http://localhost:8000
7. Build and install the Android app to monitor from your phone
