@echo off
REM Builds BambuMonitor.exe - a standalone app, no Python install needed
REM to run it afterward, no console window, lives in the system tray.
REM Run this once from the project root (where launcher_tray.py lives).

setlocal
cd /d "%~dp0\.."

if not exist "venv\Scripts\activate.bat" (
    echo ERROR: run install_windows.bat first to set up the environment.
    pause
    exit /b 1
)
call venv\Scripts\activate.bat

echo [1/2] Installing build tool...
pip install -q pyinstaller pystray pillow

echo [2/2] Building BambuMonitor.exe (this takes a minute or two)...
pyinstaller --onefile --windowed --name "BambuMonitor" ^
    --add-data "config.example.yaml;." ^
    launcher_tray.py

echo.
echo ============================================
echo  Build complete.
echo  EXE: dist\BambuMonitor.exe
echo ============================================
echo.
echo Next: run scripts\build_installer.bat to wrap this into a proper
echo Setup.exe with a Start Menu entry, desktop shortcut and uninstaller.
pause
