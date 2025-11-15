@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   PostgreSQL Database Installation
echo ========================================
echo.

:: Check if PostgreSQL is already installed
where psql >nul 2>&1
if %errorLevel% equ 0 (
    echo PostgreSQL is already installed!
    psql --version
    echo.
    choice /C YN /M "Reinstall PostgreSQL"
    if errorlevel 2 exit /b 0
)

:: Check for installer
set "PG_INSTALLER=postgresql-15-windows-x64.exe"
if not exist "%PG_INSTALLER%" (
    echo.
    echo ERROR: PostgreSQL installer not found!
    echo.
    echo Please download PostgreSQL 15 from:
    echo https://www.postgresql.org/download/windows/
    echo.
    echo Save the installer as: %PG_INSTALLER%
    echo in this directory and run the installation again.
    echo.
    pause
    exit /b 1
)

echo.
echo Installing PostgreSQL 15...
echo.
echo IMPORTANT: During installation:
echo   - Port: 5432 (default)
echo   - Database: medical_app_db
echo   - Username: postgres
echo   - Password: (you will be asked to set this)
echo.
echo Please remember the password you set!
echo.

:: Run installer in silent mode if available
if exist "%PG_INSTALLER%" (
    echo Starting PostgreSQL installer...
    start /wait "" "%PG_INSTALLER%" --mode unattended --superpassword "Postgres123!" --servicename "postgresql" --servicepassword "Postgres123!" --serverport 5432
    
    if %errorLevel% equ 0 (
        echo.
        echo PostgreSQL installed successfully!
        echo.
        
        :: Wait for service to start
        timeout /t 5 /nobreak >nul
        
        :: Add PostgreSQL bin to PATH for this session
        set "PG_PATH=C:\Program Files\PostgreSQL\15\bin"
        if exist "%PG_PATH%" (
            set "PATH=%PATH%;%PG_PATH%"
            
            :: Verify installation
            psql --version >nul 2>&1
            if %errorLevel% equ 0 (
                echo PostgreSQL is ready to use!
                psql --version
            ) else (
                echo WARNING: PostgreSQL installed but not in PATH.
                echo You may need to restart your computer.
            )
        )
    ) else (
        echo.
        echo ERROR: PostgreSQL installation failed!
        echo Please install manually from:
        echo https://www.postgresql.org/download/windows/
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   PostgreSQL Installation Complete!
echo ========================================
echo.
echo Default Settings:
echo   - Port: 5432
echo   - Service: postgresql
echo.
pause




