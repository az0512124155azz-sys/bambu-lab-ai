@echo off
REM Bambu Lab AI Monitor - Start the server

setlocal enabledelayedexpansion

echo =========================================
echo Bambu Lab AI Monitor - Starting...
echo =========================================
echo.

REM Activate virtual environment
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found
    echo Please run: install_windows.bat
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

REM Check for config.yaml
if not exist "config.yaml" (
    echo ERROR: config.yaml not found
    echo Please edit config.yaml with your printer details
    pause
    exit /b 1
)

echo Starting API server on http://localhost:8000
echo Press Ctrl+C to stop
echo.

uvicorn api:app --host 0.0.0.0 --port 8000

pause
