import firebase_admin
from firebase_admin import credentials, db

DB_URL = 'https://nids-3f976-default-rtdb.firebaseio.com/'

try:
    # Use the service account file visible in your project directory
    cred = credentials.Certificate("../serviceAccountKey.json")
    firebase_admin.initialize_app(cred, {'databaseURL': DB_URL})
    
    # Reference the root node
    ref = db.reference('network_alerts')
    print("✅ Successfully authenticated with Firebase!")
    
    # Let's write a mock alert node
    mock_payload = {
        "timestamp": "2026-07-02T13:11:00Z",
        "src_ip": "8.8.8.8",
        "dest_ip": "10.64.105.25",
        "signature": "PIPELINE TEST: Manual Database Verification",
        "severity": 1,
        "proto": "TCP",
        "country": "United States",
        "city": "Ashburn"
    }
    
    new_node = ref.push(mock_payload)
    print(f"🚀 Data pushed successfully! New key: {new_node.key}")
    print("Look at your browser window right now!")

except Exception as e:
    print(f"❌ Connection Error: {e}")