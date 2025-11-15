@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Desktop Application Installation
echo ========================================
echo.

set "APP_DIR=C:\MedicalAppointmentSystem\App"
set "SOURCE_APP=build\windows\runner\Release"

:: Check if build exists
if not exist "%SOURCE_APP%\medical_appointment_system.exe" (
    echo.
    echo ERROR: Application executable not found!
    echo.
    echo Expected location: %SOURCE_APP%\medical_appointment_system.exe
    echo.
    echo Please build the application first by running:
    echo   flutter build windows --release
    echo.
    echo OR
    echo.
    echo If you have a pre-built package, extract it to this directory.
    echo.
    pause
    exit /b 1
)

:: Create application directory
if not exist "%APP_DIR%" mkdir "%APP_DIR%"

:: Copy application files
echo [1/3] Copying application files...
xcopy /E /I /Y "%SOURCE_APP%\*" "%APP_DIR%\" >nul

if exist "%APP_DIR%\medical_appointment_system.exe" (
    echo Application files copied successfully.
) else (
    echo ERROR: Failed to copy application files!
    pause
    exit /b 1
)

:: Create configuration file
echo.
echo [2/3] Creating application configuration...
set "CONFIG_FILE=%APP_DIR%\config.json"
if not exist "%CONFIG_FILE%" (
    (
        echo {
        echo   "apiUrl": "http://localhost:3000",
        echo   "environment": "production",
        echo   "version": "1.0.0"
        echo }
    ) > "%CONFIG_FILE%"
    echo Configuration file created.
)

:: Verify installation
echo.
echo [3/3] Verifying installation...
if exist "%APP_DIR%\medical_appointment_system.exe" (
    echo Application installed successfully!
    echo.
    echo Location: %APP_DIR%
    echo Executable: medical_appointment_system.exe
) else (
    echo ERROR: Installation verification failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Application Installation Complete!
echo ========================================
echo.
echo Application is ready to use!
echo.
pause




