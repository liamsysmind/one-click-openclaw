@echo off
chcp 65001 >nul 2>&1
:: ============================================================
::  Start OpenClaw
::  Double-click to start
:: ============================================================

echo.
echo   =============================================
echo    Starting OpenClaw...
echo   =============================================
echo.

REM Run doctor check
wsl -d openclaw bash -lc "openclaw doctor"
if %errorLevel% neq 0 (
    echo.
    echo   [ERROR] Doctor check failed. Please run START-HERE.bat first.
    echo.
    pause
    exit /b 1
)

echo.

REM Re-enable keepalive cron
wsl -d openclaw bash -lc "(crontab -l 2>/dev/null | grep -v keepalive.sh; echo '*/5 * * * * ~/.openclaw/keepalive.sh') | crontab -"

REM Start gateway
wsl -d openclaw bash -lc "openclaw gateway start"
if %errorLevel% neq 0 (
    echo.
    echo   [ERROR] Failed to start OpenClaw.
    echo.
    pause
    exit /b 1
)

echo   Waiting for gateway to be ready...
timeout /t 5 /nobreak >nul

REM Show status
wsl -d openclaw bash -lc "openclaw gateway status"

echo.
echo   OpenClaw started!
echo   Web UI: http://localhost:18789
echo.
pause
