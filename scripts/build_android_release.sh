#!/bin/bash
# Bambu Lab AI Monitor - Build Release APK for Android
# Usage: ./scripts/build_android_release.sh
# Output: android/app/build/outputs/bundle/release/app-release.aab (for Google Play)
#         android/app/build/outputs/apk/release/app-release.apk (direct install)

set -e

echo "========================================"
echo " Bambu Lab AI Monitor - Android Builder"
echo "========================================"
echo ""

cd "$(dirname "$0")/../android"

# Check for Gradle wrapper
if [ ! -f gradlew ]; then
    echo "ERROR: gradlew not found. You need to:"
    echo "1. Open the 'android' folder in Android Studio"
    echo "2. Wait for Gradle setup to complete"
    echo "3. Then run this script again"
    echo ""
    echo "Or download Android Studio from: https://developer.android.com/studio"
    exit 1
fi

# Check for Android SDK
if [ -z "$ANDROID_HOME" ]; then
    echo "WARNING: ANDROID_HOME not set. This will use Android Studio's SDK."
fi

echo "[1/3] Building debug APK..."
./gradlew assembleDebug

echo ""
echo "[2/3] Building release APK..."
echo "Note: For Play Store, you need to sign the APK with your keystore."
./gradlew assembleRelease

echo ""
echo "[3/3] Build complete!"
echo ""
echo "Output files:"
echo "  Debug APK:   ./app/build/outputs/apk/debug/app-debug.apk"
echo "  Release APK: ./app/build/outputs/apk/release/app-release.apk"
echo ""
echo "To install on your phone:"
echo "  1. Connect Android phone via USB"
echo "  2. Enable Developer Mode: Settings > About > Build Number (tap 7 times)"
echo "  3. Enable USB Debugging: Settings > Developer Options > USB Debugging"
echo "  4. Run: adb install app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "Or copy the APK file to your phone and open it to install."
