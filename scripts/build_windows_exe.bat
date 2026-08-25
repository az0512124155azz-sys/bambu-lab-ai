@echo off
REM Bambu Lab AI Monitor - Build Windows EXE Installer
REM Creates a standalone EXE file for distribution

setlocal enabledelayedexpansion

echo ========================================
echo Building Windows EXE Installer...
echo ========================================
echo.

where python >nul 2>nul
if errorlevel 1 (
    echo ERROR: Python not found
    echo Install from https://python.org
    exit /b 1
)

python --version
echo.

echo [1/5] Installing PyInstaller...
pip install pyinstaller -q

echo [2/5] Creating build directory...
if not exist build\windows mkdir build\windows
cd build\windows

echo [3/5] Copying application files...
xcopy ..\..\backend backend /E /I /Y >nul
xcopy ..\..\android android /E /I /Y >nul
copy ..\..\*.md . >nul 2>&1
copy ..\..\config.example.yaml . >nul 2>&1
copy ..\..\requirements.txt . >nul 2>&1

echo [4/5] Creating launcher script...
(
    echo import os
    echo import sys
    echo from pathlib import Path
    echo.
    echo backend_path = Path(__file__).parent / "backend"
    echo sys.path.insert(0, str(backend_path))
    echo os.chdir(str(backend_path))
    echo.
    echo if __name__ == "__main__":
    echo     import uvicorn
    echo     uvicorn.run("api:app", host="0.0.0.0", port=8000, log_level="info")
) > launcher.py

echo [5/5] Building EXE with PyInstaller...
pyinstaller --onefile --windowed --name "BambuMonitor" launcher.py

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo EXE Location:
echo   .\dist\BambuMonitor.exe
echo.
echo Next steps:
echo   1. Copy config.example.yaml to config.yaml
echo   2. Edit config.yaml with your printer details
echo   3. Run BambuMonitor.exe
echo.
cd ../..
pause
