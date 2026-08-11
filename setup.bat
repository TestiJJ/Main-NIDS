@echo off
TITLE NIDS Security Setup
COLOR 0A

echo =======================================
echo          NIDS Agent Setup for Windows
echo =======================================
echo.

:: 1. Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Python not found. Downloading Python...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile '%TEMP%\python_installer.exe'"
    echo [*] Installing Python...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    set "PATH=%PATH%;C:\Program Files\Python311\;C:\Program Files\Python311\Scripts\;"
) else (
    echo [+] Python detected successfully.
)

:: 2. Install Npcap
echo [*] Checking for Npcap...
if exist "C:\Windows\System32\Npcap" (
    echo [+] Npcap is already installed.
) else (
    echo [*] Downloading Npcap...
    powershell -Command "Invoke-WebRequest -Uri 'https://npcap.com/dist/npcap-1.79.exe' -OutFile '%TEMP%\npcap_installer.exe'"
    echo [*] Installing Npcap...
    "%TEMP%\npcap_installer.exe" /S
    echo [+] Npcap installation completed!
)

:: 3. Install Suricata
echo [*] Checking for Suricata...
if exist "C:\Program Files\Suricata" (
    echo [+] Suricata is already installed.
) else (
    echo [*] Downloading Suricata...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.openinfosecfoundation.org/downloads/windows/Suricata-7.0.6-1-64bit.msi' -OutFile '%TEMP%\suricata.msi'"
    echo [*] Installing Suricata...
    msiexec.exe /i "%TEMP%\suricata.msi" /quiet /norestart
    echo [+] Suricata installed successfully!
)

:: 4. Install Python Dependencies
echo [*] Installing required Python libraries...
python -m pip install --upgrade pip
python -m pip install requests

:: 5. Deploy Files
echo [*] Deploying agent files to C:\nids_agent\...
if not exist "C:\nids_agent" mkdir C:\nids_agent
if exist "nids_bridge.py" (
    copy /y nids_bridge.py C:\nids_agent\ >nul
    echo [+] nids_bridge.py deployed successfully.
) else (
    echo [!] WARNING: nids_bridge.py not found in current folder!
)

echo.
echo =======================================
echo   Setup complete! Run your agent using:
echo   python C:\nids_agent\nids_bridge.py
echo =======================================
pause
exit
