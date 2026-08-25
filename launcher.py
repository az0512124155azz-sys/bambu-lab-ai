#!/bin/bash
# Simple launcher for Bambu Lab AI Monitor
# This will be packaged into a Windows EXE

import os
import sys
import subprocess
from pathlib import Path

def main():
    """Start the Bambu Lab AI Monitor API server"""
    
    # Get the directory where this script is located
    script_dir = Path(__file__).parent.resolve()
    
    # Set up paths
    os.chdir(str(script_dir))
    
    # Import and run the API
    try:
        import uvicorn
        print("Starting Bambu Lab AI Monitor...")
        print("Access the web interface at: http://localhost:8000")
        print("Press Ctrl+C to stop\n")
        
        uvicorn.run(
            "api:app",
            host="0.0.0.0",
            port=8000,
            log_level="info"
        )
    except ImportError:
        print("ERROR: Required packages not found")
        print("Please run: pip install fastapi uvicorn pyyaml paho-mqtt pillow requests")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
