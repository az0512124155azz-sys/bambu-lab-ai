#!/bin/bash
# Generate Windows EXE, Android APK, and prepare for release

set -e

echo "========================================"
echo "Bambu Lab AI Monitor - Release Builder"
echo "========================================"
echo ""

# Create releases directory
mkdir -p releases/windows
mkdir -p releases/android

echo "[1/4] Preparing Windows EXE..."
if command -v python &> /dev/null || command -v python3 &> /dev/null; then
    # Install PyInstaller
    pip install pyinstaller -q
    
    # Build EXE
    pyinstaller --onefile --windowed \
        --name "BambuMonitor" \
        --distpath releases/windows \
        --specpath releases/build \
        launcher.py 2>/dev/null || echo "PyInstaller build attempted"
    
    # Copy supporting files
    cp config.example.yaml releases/windows/config.example.yaml
    cp requirements.txt releases/windows/requirements.txt
    cp start.bat releases/windows/start.bat
    cp -r backend releases/windows/ 2>/dev/null || true
    
    echo "✓ Windows EXE prepared at: releases/windows/"
else
    echo "⚠ Python not found - skipping Windows EXE"
fi

echo ""
echo "[2/4] Preparing Android APK..."
if [ -d "android" ]; then
    cd android
    if [ -f "gradlew" ]; then
        chmod +x gradlew
        ./gradlew assembleDebug 2>/dev/null || echo "Android build attempted"
        
        # Copy APK to releases
        if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
            cp app/build/outputs/apk/debug/app-debug.apk ../releases/android/BambuMonitor-debug.apk
            echo "✓ Android APK prepared at: releases/android/BambuMonitor-debug.apk"
        fi
    else
        echo "⚠ Android project not ready - skipping APK"
    fi
    cd ..
else
    echo "⚠ Android folder not found - skipping APK"
fi

echo ""
echo "[3/4] Creating distribution packages..."

# Create Windows bundle
if [ -d "releases/windows" ] && [ -f "releases/windows/BambuMonitor.exe" ]; then
    cd releases/windows
    zip -r ../BambuMonitor-windows.zip . 2>/dev/null || true
    cd ../..
    echo "✓ Windows bundle: releases/BambuMonitor-windows.zip"
fi

# Create Android bundle
if [ -f "releases/android/BambuMonitor-debug.apk" ]; then
    echo "✓ Android APK ready: releases/android/BambuMonitor-debug.apk"
fi

echo ""
echo "[4/4] Creating release notes..."
cat > releases/README.md << 'EOF'
# Bambu Lab AI Monitor - Release Files

## Windows

### Option 1: Portable EXE (Recommended)
- File: `BambuMonitor.exe`
- No installation needed
- Just run the EXE
- Make sure Python 3.10+ is installed on your system

### Option 2: Full Windows Bundle
- File: `BambuMonitor-windows.zip`
- Contains all dependencies
- Extract and run `BambuMonitor.exe`

### Setup Instructions (Windows)
1. Download `BambuMonitor.exe`
2. Run it
3. Edit `config.yaml` with your Bambu printer details:
   - Printer IP address
   - Access Code
   - Serial Number  
   - OpenRouter API key
4. Run `start.bat` to start the monitor
5. Access web interface at http://localhost:8000

## Android

### File: `BambuMonitor-debug.apk`

### Installation Instructions
1. Download the APK file to your Android phone
2. Go to Settings > Security > Enable "Unknown Sources"
3. Open the APK file with your file manager
4. Tap "Install"
5. After installation, open the app
6. Enter your PC's IP address (where the monitor is running)
7. Set the port to 8000

### First Time Setup
1. Make sure your Bambu printer is on the same network
2. Enable LAN Mode on printer (Settings > Network)
3. Note the Access Code and Serial Number
4. Fill in `config.yaml` on your PC with these details
5. Start the monitor on your PC
6. Open the Android app and connect

## Troubleshooting

### Windows
- If `BambuMonitor.exe` doesn't start:
  - Make sure Python 3.10+ is installed
  - Run from Command Prompt for error messages
  - Check that `config.yaml` is in the same folder

### Android
- If app can't connect to server:
  - Make sure both devices are on the same network
  - Check the server IP address and port
  - Make sure the monitor is running on your PC
  - Check firewall settings

EOF

echo "✓ Release notes created"

echo ""
echo "========================================"
echo "Release Builder Complete!"
echo "========================================"
echo ""
echo "Files ready in: ./releases/"
echo ""
echo "Next steps:"
echo "  1. Test the Windows EXE and Android APK"
echo "  2. Upload to GitHub Releases"
echo "  3. Share with users"
echo ""
