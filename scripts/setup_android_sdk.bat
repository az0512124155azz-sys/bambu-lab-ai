@echo off
REM Bambu Lab AI Monitor - Android SDK Setup Helper
REM This downloads and configures Android SDK for building APKs on Windows

setlocal enabledelayedexpansion

echo =========================================
echo Bambu Lab AI Monitor - Android Setup
echo =========================================
echo.

echo This script will help you set up Android development tools.
echo.
echo OPTION 1: Download Android Studio (Recommended)
echo   Visit: https://developer.android.com/studio
echo   Install and open the android/ folder
echo.
echo OPTION 2: Manual SDK Setup
echo   Download Command Line Tools from:
echo   https://developer.android.com/studio#command-tools
echo.

echo What would you like to do?
echo 1 - Open Android Studio download page
echo 2 - Show manual SDK setup instructions
echo 3 - Exit
echo.

set /p choice="Enter choice (1-3): "

if "%choice%"=="1" (
    start https://developer.android.com/studio
    echo Opening browser...
    pause
) else if "%choice%"=="2" (
    echo.
    echo Manual Android SDK Setup:
    echo ============================
    echo 1. Download: https://developer.android.com/studio#command-tools
    echo 2. Extract to: C:\Android\cmdline-tools
    echo 3. Set ANDROID_HOME environment variable:
    echo    setx ANDROID_HOME C:\Android
    echo 4. Install SDK packages:
    echo    cd C:\Android\cmdline-tools\bin
    echo    sdkmanager --install "platforms;android-34" "build-tools;34.0.0"
    echo 5. Copy the android/ folder from this repo
    echo 6. Run: cd android && gradlew assembleDebug
    echo.
    pause
) else (
    echo Exiting...
    exit /b 0
)
