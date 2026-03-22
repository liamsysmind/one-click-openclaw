@echo off
chcp 65001 >nul 2>&1
:: ============================================================
::  Stop OpenClaw
::  Double-click to stop
:: ============================================================

echo.
echo   =============================================
echo    Stopping OpenClaw...
echo   =============================================
echo.

REM Disable keepalive cron so it won't restart
wsl -d openclaw bash -lc "crontab -l 2>/dev/null | grep -v keepalive.sh | crontab -"

REM Stop gateway
wsl -d openclaw bash -lc "openclaw gateway stop"
if %errorLevel% neq 0 (
    echo.
    echo   [ERROR] Failed to stop. OpenClaw may not be running.
    echo.
    pause
    exit /b 1
)

echo.

REM Show status
wsl -d openclaw bash -lc "openclaw gateway status"

echo.
echo   OpenClaw stopped.
echo.
pause
