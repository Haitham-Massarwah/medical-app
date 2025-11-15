@echo off
echo ========================================
echo   Starting Development Server
echo ========================================
echo.

cd /d "%~dp0"

echo Checking configuration...
powershell -ExecutionPolicy Bypass -Scope Process -File ".\scripts\start-dev-auto.ps1"

pause

