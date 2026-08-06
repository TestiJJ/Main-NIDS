@echo off
TITLE NIDS Security Setup
COLOR 0A

echo =======================================
echo          NIDS Agent Setup for Windows
echo =======================================
echo.

:: 1. Check if Python is installed and added to PATH
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Python is not detected or not added to PATH.
    echo [!] Please install Python from python.org and ensure "Add python.exe to PATH" is checked.
    goto error
) else (
    echo [+] Python detected successfully.
)

:: 2. Download and Install Suricata automatically
echo [*] Checking/Downloading Suricata for Windows...
if not exist "C:\Program Files\Suricata" (
    echo [*] Downloading Suricata installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.openinfosecfoundation.org/downloads/windows/Suricata-7.0.6-1-64bit.msi' -OutFile '%TEMP%\suricata.msi'"
    
    if not exist "%TEMP%\suricata.msi" (
        echo [!] ERROR: Failed to download Suricata installer. Check your internet connection.
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

:: 3. Upgrade pip and install required dependencies
echo [*] Installing required Python libraries (requests)...
python -m pip install --upgrade pip >nul 2>&1
python -m pip install requests

if %errorlevel% neq 0 (
    echo [!] ERROR: Failed to install required libraries via pip.
    goto error
) else (
    echo [+] All dependencies installed successfully!
)

echo.
echo =======================================
echo   Setup complete! You can now run your agent:
echo   python nids_bridge.py
echo =======================================
pause
exit

:error
echo.
echo [!] Setup failed. Please fix the error above and try again.
pause
exit
