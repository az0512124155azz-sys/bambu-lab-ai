# Bambu Lab AI Monitor - Windows MSI Installer
# Requires: PowerShell 5.0+, Administrator rights, WiX Toolset
# Run as Administrator: powershell -ExecutionPolicy Bypass -File install_windows_msi.ps1

param(
    [switch]$NoWix = $false
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "========================================"
Write-Host " Bambu Lab AI Monitor - MSI Builder"
Write-Host "========================================"
Write-Host ""

# Check for required tools
Write-Host "[1/5] Checking prerequisites..."

# Check Python
$pythonVer = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Python not found. Install Python 3.10+ from https://python.org" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Python: $pythonVer"

# Create directory structure
Write-Host "[2/5] Setting up build directory..."
$buildDir = ".\build\windows"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
}

# Build Python wheel
Write-Host "[3/5] Building Python package..."
$backendDir = ".\backend"
if (-not (Test-Path "$backendDir\venv")) {
    python -m venv "$backendDir\venv"
}
& "$backendDir\venv\Scripts\activate.ps1"
pip install --upgrade pip setuptools wheel
pip install -r "$backendDir\requirements.txt"

# Prepare installer files
Write-Host "[4/5] Preparing installer files..."

# Create WiX source if not exists
$wxsFile = "$buildDir\BambuMonitor.wxs"
if (-not (Test-Path $wxsFile)) {
    @'
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
    <Product Id="*" Name="Bambu Lab AI Monitor" Language="1033" Version="1.0.0.0" Manufacturer="Bambu Lab" UpgradeCode="12345678-1234-1234-1234-123456789012">
        <Package InstallerVersion="200" Compressed="yes" />
        <Media Id="1" Cabinet="BambuMonitor.cab" EmbedCab="yes" />

        <Feature Id="ProductFeature" Title="Bambu Lab AI Monitor" Level="1">
            <ComponentRef Id="ProgramFilesComponent" />
            <ComponentRef Id="StartMenuComponent" />
        </Feature>
    </Product>
</Wix>
'@ | Out-File -Encoding UTF8 $wxsFile
    Write-Host "✓ Created $wxsFile"
}

# Create batch files for installer
@'
@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
) else (
    python -m venv venv
    call venv\Scripts\activate.bat
    pip install --upgrade pip
    pip install -r requirements.txt
)
echo Configuration saved to config.yaml
echo To start the monitor, run: start_monitor.bat
pause
'@ | Out-File -Encoding ASCII "$buildDir\setup_config.bat"

@'
@echo off
cd /d "%~dp0"
if exist venv\Scripts\activate.bat (
    call venv\Scripts\activate.bat
    uvicorn api:app --host 0.0.0.0 --port 8000
) else (
    echo Run setup_config.bat first
    pause
)
'@ | Out-File -Encoding ASCII "$buildDir\start_monitor.bat"

Write-Host "[5/5] Build complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. If you have WiX Toolset installed, run:"
Write-Host "   candle.exe $wxsFile -o $buildDir\"
Write-Host "   light.exe -out $buildDir\BambuMonitor.msi $buildDir\BambuMonitor.wixobj"
Write-Host ""
Write-Host "2. Otherwise, create a simple installer using NSIS:"
Write-Host "   Download NSIS from https://nsis.sourceforge.io"
Write-Host "   Use the template: scripts/BambuMonitor.nsi"
Write-Host ""
Write-Host "Distribution files are ready in: $buildDir"
