@echo off
:: ============================================================
::  OpenClaw Installer Launcher
::  Double-click to start
:: ============================================================

echo.
echo   =============================================
echo    OpenClaw Windows Installer
echo   =============================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo   Need admin rights. Click YES on the next prompt...
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo   Unblocking files...
powershell -Command "Get-ChildItem '%~dp0' -Recurse | Unblock-File" >nul 2>&1

if not exist "%~dp0install-openclaw.ps1" (
    echo.
    echo   [ERROR] install-openclaw.ps1 not found!
    echo.
    echo   All files must be in the same folder:
    echo     - START-HERE.bat
    echo     - install-openclaw.ps1
    echo     - setup-openclaw.sh
    echo.
    echo   If Windows blocked the files:
    echo     1. Right-click the .zip file, select Properties
    echo     2. Check "Unblock" at the bottom, click OK
    echo     3. Delete this folder and re-extract the zip
    echo.
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%~dp0install-openclaw.ps1"
pause
