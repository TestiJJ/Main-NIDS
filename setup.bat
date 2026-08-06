@echo off
TITLE NIDS Ultimate Automated Setup
COLOR 0A

:: Ensure script runs with Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Please right-click this script and select "Run as administrator".
    goto error
)

echo ===================================================
echo     NIDS Agent & Environment Full Auto-Installer
echo ===================================================
echo.

:: Set script root directory
set "SCRIPT_DIR=%~dp0"

:: Add common Python installation paths to PATH for this session immediately
set "PATH=%PATH%;C:\Program Files\Python311\;C:\Program Files\Python311\Scripts\;C:\Python311\;C:\Python311\Scripts\"

:: 1. Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Python not detected. Downloading Python installer...
    
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile '%TEMP%\python_installer.exe'"
    
    if not exist "%TEMP%\python_installer.exe" (
        echo [!] ERROR: Failed to download Python. Check your internet connection.
        goto error
    )

    echo [*] Installing Python silently and adding to PATH (this may take a moment)...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1
    
    :: Force update session PATH to include standard installation directories
    set "PATH=%PATH%;C:\Program Files\Python311\;C:\Program Files\Python311\Scripts\;C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python311\;C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python311\Scripts\"
    timeout /t 3 >nul
) else (
    echo [+] Python is already installed.
)

:: Verify Python is now working
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Python installation finished, but it is not available in PATH.
    echo [!] Please restart your terminal/PC and run this script again.
    goto error
) else (
    echo [+] Python is verified and ready.
)

:: 2. Download and Install Suricata automatically
echo [*] Checking/Downloading Suricata for Windows...
if not exist "C:\Program Files\Suricata" (
    echo [*] Downloading Suricata installer...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://www.openinfosecfoundation.org/downloads/windows/Suricata-7.0.17-1-64bit.msi' -OutFile '%TEMP%\suricata.msi'"
    
    if not exist "%TEMP%\suricata.msi" (
        echo [!] ERROR: Failed to download Suricata installer.
        goto error
    )

    echo [*] Installing Suricata silently...
    msiexec.exe /i "%TEMP%\suricata.msi" /quiet /norestart
    
    if %errorlevel% neq 0 (
        echo [!] ERROR: Suricata installation failed.
        goto error
    )
    echo [+] Suricata installed successfully!
) else (
    echo [+] Suricata is already installed.
)

:: 3. Create opt/agent directory, copy files, and install pip packages
echo [*] Setting up agent environment directory...
if not exist "C:\nids_agent" mkdir "C:\nids_agent"

:: Copy nids_bridge.py if present in script directory, otherwise create it inline
if exist "%SCRIPT_DIR%nids_bridge.py" (
    copy /y "%SCRIPT_DIR%nids_bridge.py" "C:\nids_agent\" >nul
    echo [+] nids_bridge.py copied successfully.
) else (
    echo [*] nids_bridge.py not found alongside installer. Generating file directly in C:\nids_agent\...
    (
        echo import json
        echo import time
        echo import os
        echo import sys
        echo import getpass
        echo import requests
        echo import smtplib
        echo from email.mime.text import MIMEText
        echo from email.mime.multipart import MIMEMultipart
        echo DB_URL = 'https://nids-3f976-default-rtdb.firebaseio.com/'
        echo if sys.platform.startswith^('win'^):
        echo     EVE_FILE = r"C:\ProgramData\Suricata\log\eve.json"
        echo else:
        echo     EVE_FILE = '/var/log/suricata/eve.json'
        echo CONFIG_FILE = 'sensor_config.json'
        echo FIREBASE_WEB_API_KEY = "AIzaSyCVS9na3K2hE9yyWWJulcBKHPXFkiMRExk"
        echo SMTP_SERVER = "smtp.gmail.com"
        echo SMTP_PORT = 587
        echo SENDER_EMAIL = "testimonyjokotoye65@gmail.com"
        echo SENDER_PASSWORD = "ovqscidivcalbowg"
        echo ALERT_COOLDOWN_SECONDS = 60
        echo last_sent_times = {}
        echo print^("✅ NIDS Client Engine Ready ^(Serverless REST Auth Mode^)"^)
        echo def authenticate_user^(^):
        echo     if "--logout" in sys.argv and os.path.exists^(CONFIG_FILE^):
        echo         os.remove^(CONFIG_FILE^)
        echo         print^("🚪 Logged out active sensor session."^)
        echo     if os.path.exists^(CONFIG_FILE^):
        echo         try:
        echo             with open^(CONFIG_FILE, 'r'^) as f:
        echo                 config = json.load^(f^)
        echo                 if config.get^("uid"^) and config.get^("email"^) and config.get^("alert_emails"^) and config.get^("idToken"^):
        echo                     print^(f"🔑 Active Sensor Owner: {config['email']} ^(UID: {config['uid']}^)"^)
        echo                     print^(f"📧 Threat Notifications Routed to: {config['alert_emails']}"^)
        echo                     return config["uid"], config["email"], config["alert_emails"], config["idToken"]
        echo         except Exception:
        echo             pass
        echo     print^("\n" + "="*50^)
        echo     print^("🔐 PROJECT NIDS SENSOR AUTHENTICATION"^)
        echo     print^("="*50^)
        echo     email = input^("Enter NIDS Admin Email: "^).strip^(^)
        echo     password = getpass.getpass^("Enter Password: "^).strip^(^)
        echo     auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
        echo     payload = {"email": email, "password": password, "returnSecureToken": True}
        echo     res = requests.post^(auth_url, json=payload^)
        echo     if res.status_code != 200:
        echo         err_msg = res.json^(^).get^('error', {}^).get^('message', 'AUTHENTICATION_FAILED'^)
        echo         print^(f"❌ Login failed: {err_msg}"^)
        echo         sys.exit^(1^)
        echo     user_data = res.json^(^)
        echo     uid = user_data['localId']
        echo     user_email = user_data['email']
        echo     id_token = user_data['idToken']
        echo     print^("\n📩 NOTIFICATION SETUP:"^)
        echo     print^("You can enter multiple admin emails separated by commas"^)
        echo     raw_input_emails = input^(f"Enter Alert Emails [Press ENTER for just {user_email}]: "^).strip^(^)
        echo     if not raw_input_emails:
        echo         alert_emails = [user_email]
        echo     else:
        echo         alert_emails = [e.strip^(^) for e in raw_input_emails.split^(","^) if e.strip^(^)]
        echo     with open^(CONFIG_FILE, 'w'^) as f:
        echo         json.dump({"uid": uid, "email": user_email, "alert_emails": alert_emails, "idToken": id_token}, f, indent=4^)
        echo     print^(f"\n✅ Authenticated successfully as [{user_email}]!"^)
        echo     print^(f"📧 Alert destinations set to: {alert_emails}"^)
        echo     print^(f"💾 Session saved to {CONFIG_FILE}\n"^)
        echo     return uid, user_email, alert_emails, id_token
        echo def send_critical_email^(recipient_emails, payload^):
        echo     signature = payload.get^("signature", "Unknown Threat"^)
        echo     src_ip = payload.get^("src_ip", "0.0.0.0"^)
        echo     country = payload.get^("country", "Unknown"^)
        echo     city = payload.get^("city", "Unknown"^)
        echo     timestamp = payload.get^("timestamp", "N/A"^)
        echo     proto = payload.get^("proto", "TCP"^)
        echo     dedup_key = f"{src_ip}:{signature}"
        echo     current_time = time.time^(^)
        echo     if dedup_key in last_sent_times and ^(current_time - last_sent_times[dedup_key]^) ^< ALERT_COOLDOWN_SECONDS:
        echo         return
        echo     if isinstance^(recipient_emails, str^):
        echo         recipient_emails = [recipient_emails]
        echo     subject = f"🚨 [CRITICAL ALERT] Incident Detected: {signature}"
        echo     html_content = f"""
        echo     ^<html^>
        echo       ^<body style="font-family: Arial, sans-serif; background-color: #020617; color: #f8fafc; padding: 20px;"^>
        echo         ^<div style="max-width: 600px; margin: 0 auto; background: #0f172a; border: 1px solid #800020; border-radius: 12px; padding: 24px;"^>
        echo           ^<h2 style="color: #ef4444; margin-top: 0;"^>⚠️ Critical Intrusion Detected on Your Network^</h2^>
        echo           ^<table style="width: 100%%; text-align: left; border-collapse: collapse; margin-top: 16px;"^>
        echo             ^<tr^>^<td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;"^>SIGNATURE:^</td^>^<td style="color: #f8fafc; font-weight: bold;"^>{signature}^</td^>^</tr^>
        echo             ^<tr^>^<td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;"^>SOURCE IP:^</td^>^<td style="color: #ef4444; font-weight: bold;"^>{src_ip} ^({city}, {country}^)^</td^>^</tr^>
        echo             ^<tr^>^<td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;"^>PROTOCOL:^</td^>^<td style="color: #f8fafc;"^>{proto}^</td^>^</tr^>
        echo             ^<tr^>^<td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;"^>TIME:^</td^>^<td style="color: #f8fafc;"^>{timestamp}^</td^>^</tr^>
        echo           ^</table^>
        echo         ^</div^>
        echo       ^</body^>
        echo     ^</html^>
        echo     """
        echo     try:
        echo         server = smtplib.SMTP^(SMTP_SERVER, SMTP_PORT^)
        echo         server.starttls^(^)
        echo         server.login^(SENDER_EMAIL, SENDER_PASSWORD^)
        echo         for email in recipient_emails:
        echo             msg = MIMEMultipart^("alternative"^)
        echo             msg["Subject"] = subject
        echo             msg["From"] = SENDER_EMAIL
        echo             msg["To"] = email.strip^(^)
        echo             msg.attach^(MIMEText^(html_content, "html"^)^)
        echo             server.sendmail^(SENDER_EMAIL, email.strip^(^), msg.as_string^(^)
        echo         server.quit^(^)
        echo         last_sent_times[dedup_key] = current_time
        echo     except Exception as e:
        echo         print^(f"❌ Failed to send alert email: {e}"^)
        echo def get_ip_location^(ip_address^):
        echo     if not ip_address or ip_address.startswith^(^("127.", "192.168.", "10.", "172.16.", "169.254."^)^):
        echo         return {"country": "Internal Network", "city": "Local", "lat": 0, "lon": 0}
        echo     try:
        echo         response = requests.get^(f"http://ip-api.com/json/{ip_address}", timeout=5^)
        echo         data = response.json^(^)
        echo         if data.get^('status'^) == 'success':
        echo             return {"country": data.get^('country', 'Unknown'^), "city": data.get^('city', 'Unknown'^), "lat": data.get^('lat', 0^), "lon": data.get^('lon', 0^)}
        echo     except Exception:
        echo         pass
        echo     return {"country": "Unknown", "city": "Unknown", "lat": 0, "lon": 0}
        echo def run_bridge^(^):
        echo     sensor_uid, owner_email, alert_emails, id_token = authenticate_user^(^)
        echo     db_endpoint = f"{DB_URL}nids_alerts/{sensor_uid}.json?auth={id_token}"
        echo     if not os.path.exists^(EVE_FILE^):
        echo         os.makedirs^(os.path.dirname^(EVE_FILE^), exist_ok=True^)
        echo         open^(EVE_FILE, 'a'^).close^(^)
        echo     with open^(EVE_FILE, "r"^) as f:
        echo         f.seek^(0, os.SEEK_END^)
        echo         while True:
        echo             line = f.readline^(^)
        echo             if not line:
        echo                 time.sleep^(0.5^)
        echo                 continue
        echo             try:
        echo                 data = json.loads^(line^)
        echo                 if data.get^("event_type"^) == "alert":
        echo                     alert_info = data.get^("alert", {}^)
        echo                     src_ip = data.get^("src_ip", "0.0.0.0"^)
        echo                     severity = int^(alert_info.get^("severity", 3^)^)
        echo                     signature = alert_info.get^("signature", "Unknown Signature"^)
        echo                     geo = get_ip_location^(src_ip^)
        echo                     payload = {"user_id": sensor_uid, "timestamp": data.get^("timestamp"^), "signature": signature, "category": alert_info.get^("category", "N/A"^), "severity": severity, "src_ip": src_ip, "dest_ip": data.get^("dest_ip", "0.0.0.0"^), "proto": data.get^("proto", "Unknown"^), "country": geo['country'], "city": geo['city'], "lat": geo['lat'], "lon": geo['lon']}
        echo                     requests.post^(db_endpoint, json=payload^)
        echo                     print^(f"🚀 Cloud Alert Pushed for [{owner_email}]"^)
        echo                     if severity == 1 or "Nmap" in signature or "Exploit" in signature:
        echo                         send_critical_email^(alert_emails, payload^)
        echo             except Exception:
        echo                 continue
        echo if __name__ == "__main__":
        echo     run_bridge^(^)
    ) > "C:\nids_agent\nids_bridge.py"
    echo [+] nids_bridge.py generated successfully at C:\nids_agent\nids_bridge.py
)

if exist "%SCRIPT_DIR%requirements.txt" (
    copy /y "%SCRIPT_DIR%requirements.txt" "C:\nids_agent\" >nul
    echo [*] Installing required Python libraries from requirements.txt...
    python -m pip install --upgrade pip
    python -m pip install -r "C:\nids_agent\requirements.txt"
) else (
    echo [*] requirements.txt not found. Installing default 'requests' and 'firebase-admin'...
    python -m pip install --upgrade pip
    python -m pip install requests firebase-admin
)

if %errorlevel% neq 0 (
    echo [!] ERROR: Failed to install required libraries via pip.
    goto error
) else (
    echo [+] All Python dependencies installed successfully!
)

echo.
echo ===================================================
echo     Setup complete! Everything is installed.
echo     You can now run your agent:
echo     python C:\nids_agent\nids_bridge.py
echo ===================================================
echo.
pause
exit

:error
echo.
echo [!] Setup failed. Please review the errors above.
echo.
pause
exit
