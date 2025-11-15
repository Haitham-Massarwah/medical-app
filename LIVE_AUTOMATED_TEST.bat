@echo off
title LIVE AUTOMATED TESTING - Watch It Work!
color 0B

echo.
echo  ========================================
echo   LIVE AUTOMATED TESTING
echo  ========================================
echo.
echo  You will SEE the app running and watch
echo  as it automatically:
echo    - Logs in
echo    - Clicks buttons
echo    - Opens screens
echo    - Tests everything
echo.
echo  Screenshots saved in: test\screenshots\
echo.
echo  ========================================
echo.
pause

REM Kill existing instances
taskkill /F /IM temp_platform_project.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul

echo.
echo [1/4] Starting backend...
cd backend
start /MIN cmd /c "npm run dev"
cd..
timeout /t 10 >nul
echo Backend running!

echo.
echo [2/4] Creating screenshots folder...
if not exist "test\screenshots" mkdir "test\screenshots"
echo Folder ready: test\screenshots\

echo.
echo [3/4] Launching app for LIVE testing...
echo.
echo YOU WILL SEE THE APP OPEN!
echo WATCH as it automatically tests everything!
echo.
timeout /t 3 >nul

REM Run integration test with visible app
echo Running live tests...
echo.
flutter test integration_test\full_automated_test.dart --verbose

echo.
echo [4/4] Test complete!
echo.
echo Screenshots saved in: test\screenshots\
echo.
explorer test\screenshots
echo.
pause



