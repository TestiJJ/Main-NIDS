#!/bin/bash
echo "==================================================="
echo "     NIDS Agent & Environment Full Auto-Installer"
echo "==================================================="

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run this script with sudo: sudo ./setup.sh"
  exit 1
fi

# Detect Operating System
OS="$(uname -s)"

if [ "$OS" = "Linux" ]; then
    echo "[*] Detected Linux environment."
    echo "[*] Updating package manager and installing Suricata, Python 3, and pip..."
    apt update && apt install -y suricata python3 python3-pip python3-venv jq

elif [ "$OS" = "Darwin" ]; then
    echo "[*] Detected macOS environment."
    # Check if Homebrew is installed, install if missing
    if ! command -v brew &> /dev/null; then
        echo "[*] Homebrew not found. Installing Homebrew automatically..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "[*] Updating Homebrew and installing Suricata and Python 3..."
    brew update
    brew install suricata python3
else
    echo "[!] Unsupported operating system: $OS"
    exit 1
fi

# Ensure Suricata service is enabled and running
echo "[*] Configuring and starting Suricata service..."
systemctl enable suricata
systemctl start suricata

# Create working directory and deploy components
echo "[*] Deploying agent files to /opt/nids_agent..."
mkdir -p /opt/nids_agent

if [ -f "nids_bridge.py" ]; then
    cp nids_bridge.py /opt/nids_agent/
    echo "[+] nids_bridge.py deployed successfully."
else
    echo "[!] Warning: nids_bridge.py not found in current directory. Make sure to place it there."
fi

if [ -f "requirements.txt" ]; then
    cp requirements.txt /opt/nids_agent/
    echo "[*] Installing required Python libraries from requirements.txt..."
    python3 -m pip install --upgrade pip
    python3 -m pip install -r /opt/nids_agent/requirements.txt
else
    echo "[*] requirements.txt not found. Installing default 'requests' package..."
    python3 -m pip install requests
fi

# Set executable permissions
if [ -f "/opt/nids_agent/nids_bridge.py" ]; then
    chmod +x /opt/nids_agent/nids_bridge.py
fi

echo ""
echo "==================================================="
echo "     Setup complete! Everything is installed."
echo "     Run your agent using:"
echo "     sudo python3 /opt/nids_agent/nids_bridge.py"
echo "==================================================="
