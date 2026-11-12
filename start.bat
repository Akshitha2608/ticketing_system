@echo off
cd /d "%~dp0"
if not exist .venv py -3.12 -m venv .venv
call .venv\Scripts\activate
python -m pip install -r requirements.txt
if not exist .env copy .env.example .env
echo Edit .env and add your Neon DATABASE_URL, SECRET_KEY, ADMIN_EMAIL and ADMIN_PASSWORD.
pause
python app.py
