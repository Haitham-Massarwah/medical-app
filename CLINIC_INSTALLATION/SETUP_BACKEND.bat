@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Backend Server Setup
echo ========================================
echo.

set "BACKEND_DIR=C:\MedicalAppointmentSystem\Backend"
set "SOURCE_BACKEND=..\backend"

:: Check Node.js
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo Please run INSTALL_NODEJS.bat first.
    pause
    exit /b 1
)

echo Node.js version:
node --version
npm --version
echo.

:: Create backend directory
if not exist "%BACKEND_DIR%" mkdir "%BACKEND_DIR%"

:: Copy backend files
echo [1/4] Copying backend files...
if exist "%SOURCE_BACKEND%" (
    xcopy /E /I /Y "%SOURCE_BACKEND%\*" "%BACKEND_DIR%\" >nul
    echo Backend files copied successfully.
) else (
    echo ERROR: Backend source directory not found!
    echo Expected: %SOURCE_BACKEND%
    pause
    exit /b 1
)

:: Navigate to backend directory
cd /d "%BACKEND_DIR%"

:: Install dependencies
echo.
echo [2/4] Installing backend dependencies...
echo This may take a few minutes...
call npm install
if %errorLevel% neq 0 (
    echo ERROR: Failed to install dependencies!
    pause
    exit /b 1
)
echo Dependencies installed successfully.

:: Build TypeScript
echo.
echo [3/4] Building backend (TypeScript compilation)...
if exist "package.json" (
    call npm run build
    if %errorLevel% neq 0 (
        echo WARNING: Build failed, but continuing...
    )
)

:: Create .env file
echo.
echo [4/4] Creating configuration file...
set "ENV_FILE=%BACKEND_DIR%\.env"
if not exist "%ENV_FILE%" (
    (
        echo # Backend Configuration
        echo NODE_ENV=production
        echo PORT=3000
        echo.
        echo # Database Configuration
        echo DB_HOST=localhost
        echo DB_PORT=5432
        echo DB_NAME=medical_app_db
        echo DB_USER=postgres
        echo DB_PASSWORD=Postgres123!
        echo.
        echo # JWT Configuration
        echo JWT_SECRET=your-secret-key-change-in-production
        echo JWT_EXPIRES_IN=7d
        echo.
        echo # Email Configuration (optional)
        echo SMTP_HOST=
        echo SMTP_PORT=587
        echo SMTP_USER=
        echo SMTP_PASS=
        echo.
        echo # CORS Configuration
        echo CORS_ORIGIN=http://localhost:3000
    ) > "%ENV_FILE%"
    echo Configuration file created: %ENV_FILE%
    echo.
    echo IMPORTANT: Please edit .env file and update:
    echo   - DB_PASSWORD: Change to your PostgreSQL password
    echo   - JWT_SECRET: Change to a secure random string
    echo   - Email settings: Configure if using email features
) else (
    echo Configuration file already exists.
)

:: Setup database
echo.
echo Setting up database...
call "SETUP_DATABASE.bat"

echo.
echo ========================================
echo   Backend Setup Complete!
echo ========================================
echo.
echo Backend directory: %BACKEND_DIR%
echo.
echo To start the backend server:
echo   1. Navigate to: %BACKEND_DIR%
echo   2. Run: START_BACKEND.bat
echo   OR
echo   2. Run: npm start
echo.
pause




