@echo off
TITLE NIDS Security Agent Installer
COLOR 0A

echo ===================================================
echo       NIDS Agent Setup for Windows
echo ===================================================
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

:: 2. Upgrade pip and install required dependencies
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
echo ===================================================
echo [+] Setup complete! You can now run your agent using:
echo     python nids_bridge.py
echo ===================================================
pause
exit

:error
echo.
echo [!] Setup failed. Please fix the error above and try again.
pause
exit
