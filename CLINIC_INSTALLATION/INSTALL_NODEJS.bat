@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Node.js Installation
echo ========================================
echo.

:: Check if Node.js is already installed
where node >nul 2>&1
if %errorLevel% equ 0 (
    echo Node.js is already installed!
    node --version
    npm --version
    echo.
    choice /C YN /M "Reinstall Node.js"
    if errorlevel 2 exit /b 0
)

:: Check for installer
set "NODE_INSTALLER=node-v20-lts-x64.msi"
if not exist "%NODE_INSTALLER%" (
    echo.
    echo ERROR: Node.js installer not found!
    echo.
    echo Downloading Node.js 20 LTS...
    echo.
    
    :: Download Node.js installer
    set "NODE_URL=https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
    powershell -Command "Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%NODE_INSTALLER%'"
    
    if not exist "%NODE_INSTALLER%" (
        echo.
        echo ERROR: Failed to download Node.js!
        echo.
        echo Please download Node.js 20 LTS manually from:
        echo https://nodejs.org/
        echo.
        echo Save the installer as: %NODE_INSTALLER%
        echo in this directory and run the installation again.
        echo.
        pause
        exit /b 1
    )
)

echo.
echo Installing Node.js...
echo.

:: Run installer
if exist "%NODE_INSTALLER%" (
    echo Starting Node.js installer...
    start /wait msiexec /i "%NODE_INSTALLER%" /quiet /norestart
    
    if %errorLevel% equ 0 (
        echo.
        echo Node.js installed successfully!
        echo.
        
        :: Refresh PATH
        call refreshenv >nul 2>&1
        
        :: Verify installation
        timeout /t 3 /nobreak >nul
        node --version >nul 2>&1
        if %errorLevel% equ 0 (
            echo Node.js is ready to use!
            node --version
            npm --version
        ) else (
            echo WARNING: Node.js installed but not in PATH.
            echo You may need to restart your computer or open a new terminal.
            echo.
            echo Please restart your terminal and verify with:
            echo   node --version
        )
    ) else (
        echo.
        echo ERROR: Node.js installation failed!
        echo Please install manually from:
        echo https://nodejs.org/
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   Node.js Installation Complete!
echo ========================================
echo.
pause




