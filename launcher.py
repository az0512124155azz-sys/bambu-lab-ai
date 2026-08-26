#!/usr/bin/env python3
"""
Bambu Lab AI Monitor - Complete Installation & Launcher
This script handles both installation and running the monitor
"""

import os
import sys
import subprocess
from pathlib import Path

def install_dependencies():
    """Install all required Python packages"""
    print("  [*] Installing dependencies...")
    packages = [
        'fastapi',
        'uvicorn',
        'pyyaml',
        'paho-mqtt',
        'pillow',
        'requests',
        'opencv-python-headless'
    ]
    
    for package in packages:
        try:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-q', package])
            print(f"    ✓ {package}")
        except subprocess.CalledProcessError:
            print(f"    ✗ Failed to install {package}")
            return False
    
    return True

def setup_config():
    """Set up config.yaml if it doesn't exist"""
    config_path = Path('config.yaml')
    example_path = Path('config.example.yaml')
    
    if not config_path.exists() and example_path.exists():
        print("  [*] Creating config.yaml...")
        with open(example_path, 'r') as f:
            content = f.read()
        with open(config_path, 'w') as f:
            f.write(content)
        print("    ✓ config.yaml created from template")
        print("    ⚠ IMPORTANT: Edit config.yaml with your printer details!")
        return True
    return False

def check_config():
    """Check if config.yaml is properly configured"""
    config_path = Path('config.yaml')
    
    if not config_path.exists():
        print("    ERROR: config.yaml not found!")
        return False
    
    try:
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        
        # Check for required fields
        required = ['printer_ip', 'printer_access_code', 'printer_serial', 'openrouter_api_key']
        missing = [k for k in required if not config.get(k)]
        
        if missing:
            print("    ⚠ WARNING: Missing configuration:")
            for field in missing:
                print(f"      - {field}")
            print("    Please edit config.yaml with your printer details")
            return False
        
        print("    ✓ Configuration valid")
        return True
    except Exception as e:
        print(f"    ERROR: Failed to read config.yaml: {e}")
        return False

def start_server():
    """Start the Uvicorn server"""
    print("\n  [*] Starting Bambu Lab AI Monitor...\n")
    print("  " + "="*60)
    print("  🚀 Bambu Lab AI Monitor is Running")
    print("  " + "="*60)
    print("  📱 Web Interface: http://localhost:8000")
    print("  📚 API Docs:     http://localhost:8000/docs")
    print("  ⏹️  Press Ctrl+C to stop")
    print("  " + "="*60 + "\n")
    
    try:
        import uvicorn
        uvicorn.run(
            'api:app',
            host='0.0.0.0',
            port=8000,
            log_level='info'
        )
    except KeyboardInterrupt:
        print("\n\n  ✓ Monitor stopped.")
        sys.exit(0)
    except Exception as e:
        print(f"  ERROR: {e}")
        sys.exit(1)

def main():
    """Main entry point - Install and run"""
    
    print("\n" + "="*60)
    print("  Bambu Lab AI Monitor - Setup & Start")
    print("="*60 + "\n")
    
    # Change to script directory
    os.chdir(Path(__file__).parent)
    
    # Check if api.py exists
    if not Path('api.py').exists():
        print("  ERROR: api.py not found!")
        print("  This script must be run from the project root directory")
        sys.exit(1)
    
    # Step 1: Install dependencies
    print("[1/4] Checking dependencies...")
    if not install_dependencies():
        print("\n  ✗ Failed to install dependencies.")
        print("  Try running: pip install fastapi uvicorn pyyaml paho-mqtt pillow requests opencv-python-headless")
        sys.exit(1)
    print("  ✓ Dependencies installed\n")
    
    # Step 2: Setup config
    print("[2/4] Setting up configuration...")
    setup_config()
    print("  ✓ Configuration ready\n")
    
    # Step 3: Verify config
    print("[3/4] Verifying configuration...")
    config_valid = check_config()
    if not config_valid:
        print("\n  ⚠ Please configure config.yaml first.")
        config_path = Path('config.yaml').absolute()
        print(f"  Edit: {config_path}")
        input("  Press Enter when done...")
    print()
    
    # Step 4: Start server
    print("[4/4] Starting server...")
    start_server()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n  ✓ Shutdown requested.")
        sys.exit(0)
    except Exception as e:
        print(f"\n  FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
