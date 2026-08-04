import os
import subprocess
import sys

print("[+] Setting up Project NIDS Sensor...")

# 1. Create a virtual environment
subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)

# 2. Determine paths based on the user's operating system
if os.name == 'nt':  # Windows
    pip_path = os.path.join("venv", "Scripts", "pip")
    python_path = os.path.join("venv", "Scripts", "python")
else:  # Linux / macOS
    pip_path = os.path.join("venv", "bin", "pip")
    python_path = os.path.join("venv", "bin", "python")

# 3. Upgrade pip and install dependencies from requirements.txt
subprocess.run([pip_path, "install", "--upgrade", "pip"], check=True)
if os.path.exists("requirements.txt"):
    subprocess.run([pip_path, "install", "-r", "requirements.txt"], check=True)

print("\n[+] Setup Complete!")
print(f"[+] Run your sensor using: {python_path} nids_bridge.py")
