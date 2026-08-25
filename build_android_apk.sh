#!/usr/bin/env bash
# Builds a debug APK you can install directly on an Android phone.
# Requires: Android SDK + Gradle (or use Android Studio's "Build APK" instead).
set -e
cd "$(dirname "$0")/../android"

if [ ! -f gradlew ]; then
    echo "gradlew wrapper not found. Open this 'android' folder in Android Studio"
    echo "once (File > Open) — it will generate the wrapper automatically — then"
    echo "re-run this script, or just use Android Studio's Build > Build APK(s)."
    exit 1
fi

./gradlew assembleDebug
echo "APK built at: android/app/build/outputs/apk/debug/app-debug.apk"
echo "Copy this file to your phone and open it to install (allow 'unknown sources')."
