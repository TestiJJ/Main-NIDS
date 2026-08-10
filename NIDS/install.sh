#!/bin/bash
set -e

echo "🛡️ =========================================="
echo "   PROJECT NIDS: FULL LINUX SENSOR SETUP"
echo "============================================"

# 1. Update system packages
echo "🔄 Updating local package repositories..."
sudo apt-get update -y

# 2. Install Suricata and Python pip if missing
echo "📦 Installing Suricata and Python dependencies..."
sudo apt-get install -y suricata python3 python3-pip python3-requests

# 3. Ensure Suricata log directory structure exists with correct permissions
echo "📁 Configuring Suricata log paths..."
sudo mkdir -p /var/log/suricata
sudo touch /var/log/suricata/eve.json
sudo chmod 755 /var/log/suricata

# 4. Install any additional Python requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "📚 Installing Python modules from requirements.txt..."
    pip3 install -r requirements.txt --quiet
else
    echo "📚 Installing core python dependencies..."
    pip3 install requests --quiet
fi

echo "============================================"
echo "✅ Installation Complete! Starting NIDS Bridge..."
echo "============================================"

# 5. Launch the bridge script automatically
python3 nids_bridge.py
