@echo off
TITLE NIDS Security Agent Installer
COLOR 0A
echo ===========================================
echo       NIDS Agent Setup for Windows
echo ===========================================
echo.
python --version >nul 2>&1
if %%errorlevel%% neq 0 (
    echo [!] ERROR: Python is not detected or not added to PATH.
    goto error
) else (
    echo [+] Python detected successfully.
)
python -m pip install --upgrade pip >nul 2>&1
python -m pip install requests
echo [+] Setup complete!
pause
exit
:error
echo [!] Setup failed.
pause
