@echo off
TITLE NIDS Security Setup
COLOR 0A

echo =======================================
echo          NIDS Agent Setup for Windows
echo =======================================
echo.

:: 1. Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Python not found. Installing Python automatically...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe' -OutFile '%TEMP%\python_installer.exe'"
    
    if not exist "%TEMP%\python_installer.exe" (
        echo [!] ERROR: Failed to download Python. Check internet.
        goto error
    )

    echo [*] Running Python installer... Please wait...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    :: Refresh path for current session
    set "PATH=%PATH%;C:\Program Files\Python311\;C:\Program Files\Python311\Scripts\;"
) else (
    echo [+] Python detected successfully.
)

:: 2. Check and Install Npcap (Required for packet capture on Windows)
echo [*] Checking for Npcap...
if not exist "C:\Windows\System32\Npcap" (
    echo [*] Npcap not found. Downloading Npcap installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://npcap.com/dist/npcap-1.79.exe' -OutFile '%TEMP%\npcap_installer.exe'"
    
    if not exist "%TEMP%\npcap_installer.exe" (
        echo [!] ERROR: Failed to download Npcap. Check internet.
        goto error
    )

    echo [*] Installing Npcap silently (Admin privileges required)...
    "%TEMP%\npcap_installer.exe" /S
    echo [+] Npcap installation completed!
) else (
    echo [+] Npcap is already installed.
)

:: 3. Download and Install Suricata
echo [*] Checking/Downloading Suricata...
if not exist "C:\Program Files\Suricata" (
    powershell -Command "Invoke-WebRequest -Uri 'https://www.openinfosecfoundation.org/downloads/windows/Suricata-7.0.6-1-64bit.msi' -OutFile '%TEMP%\suricata.msi'"
    
    if not exist "%TEMP%\suricata.msi" (
        echo [!] ERROR: Failed to download Suricata. Check internet.
        goto error
    )

    msiexec.exe /i "%TEMP%\suricata.msi" /quiet /norestart
    echo [+] Suricata installed successfully!
) else (
    echo [+] Suricata is already installed.
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

:error
echo.
echo [!] Setup failed. Fix the error above and try again.
pause
exit
