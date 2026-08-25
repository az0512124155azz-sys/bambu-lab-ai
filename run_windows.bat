@echo off
call "%~dp0..\backend\venv\Scripts\activate.bat"
cd /d "%~dp0..\backend"
uvicorn api:app --host 0.0.0.0 --port 8000
