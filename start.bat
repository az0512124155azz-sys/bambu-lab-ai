@echo off
REM Quick start script for Windows
REM This installs dependencies and runs the monitor

echo Bambu Lab AI Monitor - Starting...
echo.

REM Check if Python is installed
where python >nul 2>nul
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please install Python 3.10+ from https://python.org
    pause
    exit /b 1
)

REM Install required packages
echo Installing dependencies...
if exist requirements.txt (
    pip install -q -r requirements.txt
) else (
    pip install -q fastapi uvicorn pyyaml paho-mqtt pillow requests opencv-python-headless
)

REM Check for config file
if not exist config.yaml (
    echo.
    echo WARNING: config.yaml not found!
    if exist config.example.yaml (
        echo Creating config.yaml from template...
        copy config.example.yaml config.yaml
        echo.
        echo IMPORTANT: Edit config.yaml with your printer IP and API keys
        echo.
        pause
    )
)

echo.
echo Starting API server on http://localhost:8000
echo Press Ctrl+C to stop
echo.

python launcher.py

pause
