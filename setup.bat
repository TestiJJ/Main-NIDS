@echo off
TITLE NIDS Ultimate Automated Setup
COLOR 0A

echo ===================================================
echo     NIDS Agent & Environment Full Auto-Installer
echo ===================================================
echo.

:: 1. Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Python not detected. Downloading Python installer...
    
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -OutFile '%TEMP%\python_installer.exe'"
    
    if not exist "%TEMP%\python_installer.exe" (
        echo [!] ERROR: Failed to download Python. Check your internet connection.
        goto error
    )

    echo [*] Installing Python silently and adding to PATH (this may take a moment)...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1
    
    :: Refresh environment variables for the current command window
    refreshenv >nul 2>&1
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
    powershell -Command "Invoke-WebRequest -Uri 'https://www.openinfosecfoundation.org/downloads/windows/Suricata-7.0.17-1-64bit.msi' -OutFile '%TEMP%\suricata.msi'"
    
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

:: 3. Upgrade pip and install required dependencies
echo [*] Installing required Python libraries (requests)...
python -m pip install --upgrade pip >nul 2>&1
python -m pip install requests

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
echo     python nids_bridge.py
echo ===================================================
echo.
pause
exit

:error
echo.
echo [!] Setup failed. Please ensure you ran this script as Administrator!
echo.
pause
exit
