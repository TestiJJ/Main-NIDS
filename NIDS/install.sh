#!/bin/bash
echo "🛡️ Installing Project NIDS Sensor..."

# 1. Install Suricata if not already present
sudo apt update && sudo apt install -y suricata

# 2. Create the working directory for the agent
sudo mkdir -p /opt/nids_agent
sudo cp nids_bridge /opt/nids_agent/nids_bridge
sudo chmod +x /opt/nids_agent/nids_bridge

echo "✅ Installation complete! Run the agent using:"
echo "sudo /opt/nids_agent/nids_bridge"
