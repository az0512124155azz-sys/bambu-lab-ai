@echo off
REM Bambu AI Monitor - Full installer build
REM 1) Builds BambuMonitor.exe with PyInstaller
REM 2) Wraps it into a Setup.exe wizard with Inno Setup
REM
REM Requires Inno Setup: https://jrsoftware.org/isdl.php (free, one-time install)

setlocal
cd /d "%~dp0\.."

echo [1/2] Building BambuMonitor.exe...
call scripts\build_windows_exe.bat
if not exist "dist\BambuMonitor.exe" (
    echo ERROR: BambuMonitor.exe was not produced. See errors above.
    pause
    exit /b 1
)

echo.
echo [2/2] Building Setup.exe with Inno Setup...

set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist %ISCC% set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
if not exist %ISCC% (
    echo ERROR: Inno Setup not found.
    echo Install it from https://jrsoftware.org/isdl.php then re-run this script.
    pause
    exit /b 1
)

%ISCC% scripts\BambuMonitor.iss

echo.
echo ============================================
echo  Done. Installer at: dist_installer\BambuMonitorSetup.exe
echo  Send that single file to install on any Windows PC -
echo  it adds a Start Menu entry, optional desktop icon, and
echo  a proper uninstaller. No Python required on the target PC.
echo ============================================
pause
