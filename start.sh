#!/bin/bash
# Quick start script for Mac/Linux
# This installs dependencies and runs the monitor

echo "Bambu Lab AI Monitor - Starting..."
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 not found!"
    echo "Please install Python 3.10+ from https://python.org"
    exit 1
fi

# Install required packages
echo "Installing dependencies..."
if [ -f requirements.txt ]; then
    pip3 install -q -r requirements.txt
else
    pip3 install -q fastapi uvicorn pyyaml paho-mqtt pillow requests opencv-python-headless
fi

# Check for config file
if [ ! -f config.yaml ]; then
    echo ""
    echo "WARNING: config.yaml not found!"
    if [ -f config.example.yaml ]; then
        echo "Creating config.yaml from template..."
        cp config.example.yaml config.yaml
        echo ""
        echo "IMPORTANT: Edit config.yaml with your printer IP and API keys"
        echo ""
        read -p "Press Enter to continue..."
    fi
fi

echo ""
echo "Starting API server on http://localhost:8000"
echo "Press Ctrl+C to stop"
echo ""

python3 launcher.py
