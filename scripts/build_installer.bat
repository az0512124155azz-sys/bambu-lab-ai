@echo off
REM Bambu Lab AI Monitor - Build Installers
REM Builds both portable EXE and NSIS MSI installers

setlocal enabledelayedexpansion

echo =========================================
echo Bambu Lab AI Monitor - Installer Builder
echo =========================================
echo.

REM Check for Python
where python >nul 2>nul
if errorlevel 1 (
    echo ERROR: Python not found
    echo Install from: https://python.org/downloads
    pause
    exit /b 1
)

REM Create build directory
if not exist build\windows mkdir build\windows
cd build\windows

echo [1/4] Building Python dependencies...
if not exist app mkdir app
cd ..\..\
python -m pip install --upgrade pip wheel setuptools pyinstaller

echo [2/4] Copying application files...
xcopy backend build\windows\app\backend\ /E /I /Y >nul
xcopy android build\windows\app\android\ /E /I /Y >nul
copy *.md build\windows\app\ >nul
copy *.yaml build\windows\app\ >nul
copy *.bat build\windows\app\ >nul

echo [3/4] Creating PyInstaller standalone exe...
cd build\windows
pyinstaller --onedir --windowed --name "BambuMonitor" --icon=app\app.ico app\backend\api.py
echo Output: build\windows\dist\BambuMonitor\

echo [4/4] Preparing NSIS installer...
if exist ..\..\scripts\BambuMonitor.nsi (
    copy ..\..\scripts\BambuMonitor.nsi .
    echo Run "makensis BambuMonitor.nsi" to create the .exe installer
) else (
    echo NSIS script not found
)

cd ..\..
echo.
echo Build complete!
echo Outputs in: build\windows\
echo - dist\BambuMonitor\  (portable)
echo - BambuMonitor.nsi    (for NSIS, creates MSI)
pause
