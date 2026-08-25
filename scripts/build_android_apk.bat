@echo off
REM Bambu Lab AI Monitor - Build Android APK (Windows)
REM Requires: Android Studio or Android SDK Command Line Tools

setlocal enabledelayedexpansion

echo =========================================
echo Bambu Lab AI Monitor - Android APK Build
echo =========================================
echo.

REM Check if gradlew exists
if not exist "..\android\gradlew.bat" (
    echo ERROR: Android project not found.
    echo Please ensure the android/ folder is in the project root.
    echo.
    echo If you don't have Android SDK installed, run:
    echo   scripts\setup_android_sdk.bat
    pause
    exit /b 1
)

echo [1/3] Checking Android SDK...
cd ..
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
if not exist "%ANDROID_HOME%" (
    echo ERROR: Android SDK not found at %ANDROID_HOME%
    echo.
    echo Please install Android Studio or Android SDK Command Line Tools:
    echo   https://developer.android.com/studio
    echo.
    pause
    exit /b 1
)
echo ✓ Found Android SDK

echo.
echo [2/3] Building Debug APK...
cd android
call gradlew.bat assembleDebug
if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

echo.
echo [3/3] Build complete!
echo.
echo APK Location:
echo   .\app\build\outputs\apk\debug\app-debug.apk
echo.
echo To install:
echo   1. Connect your Android phone via USB
echo   2. Enable USB Debugging in Developer Options
echo   3. Run: adb install app\build\outputs\apk\debug\app-debug.apk
echo.
echo Or copy the APK to your phone and open it.
pause
