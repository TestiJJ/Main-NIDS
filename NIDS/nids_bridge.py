cat << 'EOF' > nids_bridge.py
import json
import time
import os
import sys
import getpass
import requests
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

DB_URL = 'https://nids-3f976-default-rtdb.firebaseio.com/'
EVE_FILE = '/var/log/suricata/eve.json'
CONFIG_FILE = 'sensor_config.json'
FIREBASE_WEB_API_KEY = "AIzaSyCVS9na3K2hE9yyWWJulcBKHPXFkiMRExk"

SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = "testimonyjokotoye65@gmail.com"
SENDER_PASSWORD = "ovqscidivcalbowg"

ALERT_COOLDOWN_SECONDS = 60
last_sent_times = {}

print("✅ NIDS Client Engine Ready (Serverless REST Auth Mode)")
<<<<<<< HEAD

def authenticate_user():
=======


def authenticate_user():
    """Authenticates the user against Firebase Auth via REST API and sets alert delivery email."""
>>>>>>> 91f6adaa8070a7fbaaf10b52ea738bc65c387c01
    if "--logout" in sys.argv and os.path.exists(CONFIG_FILE):
        os.remove(CONFIG_FILE)
        print("🚪 Logged out active sensor session.")

    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
                if config.get("uid") and config.get("email") and config.get("alert_email") and config.get("idToken"):
                    print(f"🔑 Active Sensor Owner: {config['email']} (UID: {config['uid']})")
                    print(f"📧 Threat Notifications Routed to: {config['alert_email']}")
                    return config["uid"], config["email"], config["alert_email"], config["idToken"]
        except Exception:
            pass

    print("\n" + "="*50)
    print("🔐 PROJECT NIDS SENSOR AUTHENTICATION")
    print("="*50)
    
    email = input("Enter NIDS Admin Email: ").strip()
    password = getpass.getpass("Enter Password: ").strip()

    auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={FIREBASE_WEB_API_KEY}"
    payload = {"email": email, "password": password, "returnSecureToken": True}
    
    res = requests.post(auth_url, json=payload)
    if res.status_code != 200:
        err_msg = res.json().get('error', {}).get('message', 'AUTHENTICATION_FAILED')
        print(f"❌ Login failed: {err_msg}")
        sys.exit(1)
        
    user_data = res.json()
    uid = user_data['localId']
    user_email = user_data['email']
    id_token = user_data['idToken']

    print("\n📩 NOTIFICATION SETUP:")
    alert_email = input(f"Enter Email for Instant Threat Alerts [Press ENTER for {user_email}]: ").strip()
    if not alert_email:
        alert_email = user_email

    with open(CONFIG_FILE, 'w') as f:
        json.dump({
            "uid": uid, 
            "email": user_email,
            "alert_email": alert_email,
            "idToken": id_token
        }, f, indent=4)

    print(f"\n✅ Authenticated successfully as [{user_email}]!")
    print(f"📧 Alert destination set to: [{alert_email}]")
    print(f"💾 Session saved to {CONFIG_FILE}\n")
    return uid, user_email, alert_email, id_token
<<<<<<< HEAD
=======

>>>>>>> 91f6adaa8070a7fbaaf10b52ea738bc65c387c01

def send_critical_email(recipient_email, payload):
    signature = payload.get("signature", "Unknown Threat")
    src_ip = payload.get("src_ip", "0.0.0.0")
    country = payload.get("country", "Unknown")
    city = payload.get("city", "Unknown")
    timestamp = payload.get("timestamp", "N/A")
    proto = payload.get("proto", "TCP")
    
    dedup_key = f"{src_ip}:{signature}"
    current_time = time.time()
    
    if dedup_key in last_sent_times and (current_time - last_sent_times[dedup_key]) < ALERT_COOLDOWN_SECONDS:
        print(f"⏳ Throttled duplicate email for [{signature}] from [{src_ip}] (Suppressed)")
        return

    subject = f"🚨 [CRITICAL ALERT] Incident Detected: {signature}"
    html_content = f"""
    <html>
      <body style="font-family: Arial, sans-serif; background-color: #020617; color: #f8fafc; padding: 20px;">
        <div style="max-width: 600px; margin: 0 auto; background: #0f172a; border: 1px solid #800020; border-radius: 12px; padding: 24px;">
          <h2 style="color: #ef4444; margin-top: 0;">⚠️ Critical Intrusion Detected on Your Network</h2>
          <p style="font-size: 14px; color: #94a3b8;">Your private NIDS Sensor detected high-severity malicious network activity.</p>
          <table style="width: 100%; text-align: left; border-collapse: collapse; margin-top: 16px;">
            <tr><td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;">SIGNATURE:</td><td style="color: #f8fafc; font-weight: bold;">{signature}</td></tr>
            <tr><td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;">SOURCE IP:</td><td style="color: #ef4444; font-weight: bold;">{src_ip} ({city}, {country})</td></tr>
            <tr><td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;">PROTOCOL:</td><td style="color: #f8fafc;">{proto}</td></tr>
            <tr><td style="padding: 8px 0; color: #64748b; font-size: 12px; font-weight: bold;">TIME:</td><td style="color: #f8fafc;">{timestamp}</td></tr>
          </table>
          <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid #1e293b; text-align: center;">
            <p style="font-size: 12px; color: #64748b;">Project NIDS Private Console System Notification</p>
          </div>
        </div>
      </body>
    </html>
    """

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = SENDER_EMAIL
    msg["To"] = recipient_email
    msg.attach(MIMEText(html_content, "html"))

    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        server.sendmail(SENDER_EMAIL, recipient_email, msg.as_string())
        server.quit()
        last_sent_times[dedup_key] = current_time
        print(f"📧 Critical Email Dispatched to Alert Inbox ({recipient_email}) for [{signature}]")
    except Exception as e:
        print(f"❌ Failed to send alert email: {e}")

def get_ip_location(ip_address):
    if not ip_address or ip_address.startswith(("127.", "192.168.", "10.", "172.16.", "169.254.")):
        return {"country": "Internal Network", "city": "Local", "lat": 0, "lon": 0}
    try:
        response = requests.get(f"http://ip-api.com/json/{ip_address}", timeout=5)
        data = response.json()
        if data.get('status') == 'success':
            return {
                "country": data.get('country', 'Unknown'),
                "city": data.get('city', 'Unknown'),
                "lat": data.get('lat', 0),
                "lon": data.get('lon', 0)
            }
    except Exception as e:
        print(f"⚠️ Geo-IP API Error: {e}")
    return {"country": "Unknown", "city": "Unknown", "lat": 0, "lon": 0}

def run_bridge():
<<<<<<< HEAD
    sensor_uid, owner_email, alert_email, id_token = authenticate_user()
=======
    # Dynamic Authentication Check via REST API token
    sensor_uid, owner_email, alert_email, id_token = authenticate_user()
    
>>>>>>> 91f6adaa8070a7fbaaf10b52ea738bc65c387c01
    print(f"🛡️ NIDS LIVE: Routing logs to user path [/users/{sensor_uid}/network_alerts]...")
    db_endpoint = f"{DB_URL}users/{sensor_uid}/network_alerts.json?auth={id_token}"

    if not os.path.exists(EVE_FILE):
        print(f"Creating missing log file: {EVE_FILE}")
        os.makedirs(os.path.dirname(EVE_FILE), exist_ok=True)
        open(EVE_FILE, 'a').close()

    with open(EVE_FILE, "r") as f:
        f.seek(0, os.SEEK_END)
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.5)
                continue
            try:
                data = json.loads(line)
                if data.get("event_type") == "alert":
                    alert_info = data.get("alert", {})
                    src_ip = data.get("src_ip", "0.0.0.0")
                    severity = int(alert_info.get("severity", 3))
                    signature = alert_info.get("signature", "Unknown Signature")
                    
                    print(f"🔍 Threat Detected: {src_ip} -> {signature} [Sev: {severity}]")
                    geo = get_ip_location(src_ip)
                    
                    payload = {
                        "user_id": sensor_uid,
                        "timestamp": data.get("timestamp"),
                        "signature": signature,
                        "category": alert_info.get("category", "N/A"),
                        "severity": severity,
                        "src_ip": src_ip,
                        "dest_ip": data.get("dest_ip", "0.0.0.0"),
                        "proto": data.get("proto", "Unknown"),
                        "country": geo['country'],
                        "city": geo['city'],
                        "lat": geo['lat'],
                        "lon": geo['lon']
                    }
                    
<<<<<<< HEAD
                    requests.post(db_endpoint, json=payload)
                    print(f"🚀 Cloud Alert Pushed to Dashboard for [{owner_email}]")
                    
=======
                    # Push alert using secure REST API with user token
                    requests.post(db_endpoint, json=payload)
                    print(f"🚀 Cloud Alert Pushed to Dashboard for [{owner_email}]")
                    
                    # Dispatch critical email if necessary
>>>>>>> 91f6adaa8070a7fbaaf10b52ea738bc65c387c01
                    if severity == 1 or "Nmap" in signature or "Exploit" in signature:
                        send_critical_email(alert_email, payload)
            except json.JSONDecodeError:
                continue
            except Exception as e:
                print(f"❌ Loop Error: {e}")
                continue

if __name__ == "__main__":
    run_bridge()
EOF