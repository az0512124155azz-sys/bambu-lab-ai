#!/bin/bash
# Bambu Lab AI Monitor - Complete Android APK Builder
# Creates a ready-to-install APK file

set -e

echo "========================================"
echo "Building Android APK..."
echo "========================================"
echo ""

# Check if android directory exists
if [ ! -d "android" ]; then
    echo "ERROR: android/ directory not found"
    echo "Make sure you're in the project root"
    exit 1
fi

# Check for Android SDK
if [ -z "$ANDROID_HOME" ]; then
    # Try common locations
    if [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        echo "Found Android SDK at: $ANDROID_HOME"
    elif [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
        echo "Found Android SDK at: $ANDROID_HOME"
    else
        echo "ERROR: Android SDK not found"
        echo "Install Android Studio from: https://developer.android.com/studio"
        exit 1
    fi
fi

cd android

# Check for gradlew
if [ ! -f "gradlew" ]; then
    echo "ERROR: gradlew not found"
    echo "Please open the android/ folder in Android Studio first"
    exit 1
fi

# Make executable
chmod +x gradlew

echo "[1/3] Building Debug APK..."
./gradlew assembleDebug

echo ""
echo "[2/3] Building Release APK..."
./gradlew assembleRelease

echo ""
echo "========================================"
echo "APK Build Complete!"
echo "========================================"
echo ""
echo "Output files:"
echo "  Debug APK:   ./app/build/outputs/apk/debug/app-debug.apk"
echo "  Release APK: ./app/build/outputs/apk/release/app-release.apk"
echo ""
echo "To install on your phone:"
echo "  adb install app/build/outputs/apk/debug/app-debug.apk"
echo ""

cd ..
