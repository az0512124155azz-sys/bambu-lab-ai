@echo off
setlocal

echo ============================================
echo  Bambu Lab AI Monitor - Windows Installer
echo ============================================

where python >nul 2>nul
if errorlevel 1 (
    echo Python was not found. Install Python 3.10+ from https://python.org/downloads
    echo and re-run this installer.
    pause
    exit /b 1
)

echo.
echo [1/4] Creating virtual environment...
python -m venv "%~dp0..\backend\venv"

echo [2/4] Activating virtual environment...
call "%~dp0..\backend\venv\Scripts\activate.bat"

echo [3/4] Installing dependencies...
pip install --upgrade pip
pip install -r "%~dp0..\backend\requirements.txt"

echo [4/4] Setting up config...
if not exist "%~dp0..\backend\config.yaml" (
    copy "%~dp0..\backend\config.example.yaml" "%~dp0..\backend\config.yaml"
    echo Created backend\config.yaml - EDIT THIS FILE with your printer IP,
    echo access code, serial number and OpenRouter API key before starting.
)

echo.
echo Install complete.
echo To start the monitor, run: scripts\run_windows.bat
pause
