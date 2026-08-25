@echo off
REM Bambu Lab AI Monitor - Windows Installation
REM Run this first to set up the environment

setlocal enabledelayedexpansion

echo =========================================
echo Bambu Lab AI Monitor - Windows Setup
echo =========================================
echo.

REM Check for Python
where python >nul 2>nul
if errorlevel 1 (
    echo ERROR: Python 3.10+ not found
    echo.
    echo Please install from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo Python found:
python --version
echo.

REM Check if we're in the right directory
if not exist "api.py" (
    echo ERROR: api.py not found
    echo Please run this from the project root directory
    pause
    exit /b 1
)

echo [1/3] Creating Python virtual environment...
python -m venv venv

echo [2/3] Installing dependencies...
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install fastapi uvicorn pyyaml paho-mqtt pillow requests

echo.
echo [3/3] Setting up configuration...
if not exist "config.yaml" (
    if exist "config.example.yaml" (
        copy config.example.yaml config.yaml
        echo.
        echo IMPORTANT: Edit config.yaml with your printer details
    )
)

echo.
echo =========================================
echo Installation complete!
echo =========================================
echo.
echo To start the monitor, run:
echo   run_windows.bat
echo.
pause
