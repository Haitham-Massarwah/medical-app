@echo off
echo ========================================
echo   Fix Dependencies and Start Server
echo ========================================
echo.

cd /d "%~dp0"

echo Fixing corrupted packages...
call npm install --force

echo.
echo Starting server...
cmd /c "npm run dev"

pause

