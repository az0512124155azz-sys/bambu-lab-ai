#!/bin/bash
# Bambu Lab AI Monitor - Build Android APK
# Works on Mac, Linux, and Windows (Git Bash/WSL)

set -e

echo "========================================"
echo " Bambu Lab AI Monitor - Android APK"
echo "========================================"
echo ""

# Check if android directory exists
if [ ! -d "android" ]; then
    echo "ERROR: android/ directory not found"
    echo "Make sure you're running this from the project root"
    exit 1
fi

cd android

# Check for gradlew
if [ ! -f "gradlew" ]; then
    echo "ERROR: gradlew not found in android/"
    echo ""
    echo "You need to set up Android SDK first:"
    echo "1. Download Android Studio: https://developer.android.com/studio"
    echo "2. Open the 'android' folder in Android Studio"
    echo "3. Wait for Gradle setup to complete"
    echo "4. Then run this script again"
    exit 1
fi

# Make gradlew executable
chmod +x gradlew

echo "Building Debug APK..."
./gradlew assembleDebug

echo ""
echo "========================================"
echo "Build complete!"
echo "========================================"
echo ""
echo "APK location:"
echo "  ./app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "To install on your phone:"
echo "  1. Connect Android phone via USB"
echo "  2. Enable Developer Mode (tap Build Number 7 times in Settings)"
echo "  3. Enable USB Debugging in Developer Options"
echo "  4. Run: adb install app/build/outputs/apk/debug/app-debug.apk"
echo ""
