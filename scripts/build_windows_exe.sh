#!/bin/bash
# Bambu Lab AI Monitor - Complete Windows EXE Builder
# This creates a standalone EXE file ready to distribute

set -e

echo "========================================"
echo "Building Windows EXE Installer..."
echo "========================================"
echo ""

# Check Python
if ! command -v python &> /dev/null; then
    echo "ERROR: Python not found. Install from https://python.org"
    exit 1
fi

python --version
echo ""

# Install PyInstaller
echo "[1/5] Installing PyInstaller..."
pip install pyinstaller -q

# Create temp build directory
echo "[2/5] Creating build directory..."
mkdir -p build/windows
cd build/windows

# Copy source files
echo "[3/5] Copying application files..."
cp -r ../../backend .
cp -r ../../android .
cp ../../*.md .
cp ../../config.example.yaml .
cp ../../requirements.txt .

# Create entry point script
echo "[4/5] Creating launcher script..."
cat > launcher.py << 'EOF'
import os
import sys
from pathlib import Path

# Add backend to path
backend_path = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_path))

os.chdir(str(backend_path))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "api:app",
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
EOF

# Build EXE
echo "[5/5] Building EXE with PyInstaller..."
pyinstaller \
    --onefile \
    --windowed \
    --name "BambuMonitor" \
    --icon="backend/icon.ico" 2>/dev/null || \
pyinstaller \
    --onefile \
    --windowed \
    --name "BambuMonitor" \
    launcher.py

echo ""
echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""
echo "EXE Location:"
echo "  ./dist/BambuMonitor.exe"
echo ""
echo "Next steps:"
echo "  1. Copy config.example.yaml to config.yaml"
echo "  2. Edit config.yaml with your printer details"
echo "  3. Run BambuMonitor.exe"
echo ""
cd ../..
