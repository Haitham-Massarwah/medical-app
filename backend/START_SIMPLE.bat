@echo off
echo ========================================
echo   Starting Development Server
echo ========================================
echo.

cd /d "%~dp0"

echo Checking dependencies...
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
) else (
    echo Dependencies found, verifying...
    call npm install --prefer-offline --no-audit >nul 2>&1
)

echo.
echo Starting server...
cmd /c "npm run dev"

pause

