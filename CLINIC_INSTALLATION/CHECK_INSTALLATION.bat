@echo off
echo.
echo ========================================
echo   Installation Verification
echo ========================================
echo.

set "ERROR_COUNT=0"

:: Check PostgreSQL
echo [1/5] Checking PostgreSQL...
where psql >nul 2>&1
if %errorLevel% equ 0 (
    echo   [OK] PostgreSQL installed
    psql --version
) else (
    echo   [ERROR] PostgreSQL not found
    set /a ERROR_COUNT+=1
)

:: Check Node.js
echo.
echo [2/5] Checking Node.js...
where node >nul 2>&1
if %errorLevel% equ 0 (
    echo   [OK] Node.js installed
    node --version
    npm --version
) else (
    echo   [ERROR] Node.js not found
    set /a ERROR_COUNT+=1
)

:: Check Backend
echo.
echo [3/5] Checking Backend...
set "BACKEND_DIR=C:\MedicalAppointmentSystem\Backend"
if exist "%BACKEND_DIR%\package.json" (
    echo   [OK] Backend directory exists
    if exist "%BACKEND_DIR%\node_modules" (
        echo   [OK] Backend dependencies installed
    ) else (
        echo   [WARNING] Backend dependencies not installed
        echo   Run: cd "%BACKEND_DIR%" ^&^& npm install
    )
) else (
    echo   [ERROR] Backend not set up
    set /a ERROR_COUNT+=1
)

:: Check Application
echo.
echo [4/5] Checking Application...
set "APP_DIR=C:\MedicalAppointmentSystem\App"
if exist "%APP_DIR%\medical_appointment_system.exe" (
    echo   [OK] Application installed
    echo   Location: %APP_DIR%
) else (
    echo   [ERROR] Application not found
    set /a ERROR_COUNT+=1
)

:: Check Database
echo.
echo [5/5] Checking Database Connection...
where psql >nul 2>&1
if %errorLevel% equ 0 (
    set "PGPASSWORD=Postgres123!"
    psql -U postgres -h localhost -p 5432 -c "SELECT 1" >nul 2>&1
    if %errorLevel% equ 0 (
        echo   [OK] Database connection works
        psql -U postgres -h localhost -p 5432 -c "\l" | findstr /C:"medical_app_db" >nul
        if %errorLevel% equ 0 (
            echo   [OK] Database 'medical_app_db' exists
        ) else (
            echo   [WARNING] Database 'medical_app_db' not found
            echo   Run: SETUP_DATABASE.bat
        )
    ) else (
        echo   [ERROR] Cannot connect to database
        echo   Verify PostgreSQL is running and credentials are correct
        set /a ERROR_COUNT+=1
    )
)

:: Summary
echo.
echo ========================================
if %ERROR_COUNT% equ 0 (
    echo   Installation Status: SUCCESS
    echo   All components are installed and ready!
) else (
    echo   Installation Status: INCOMPLETE
    echo   Found %ERROR_COUNT% error(s)
    echo   Please fix the errors above and try again
)
echo ========================================
echo.

pause




