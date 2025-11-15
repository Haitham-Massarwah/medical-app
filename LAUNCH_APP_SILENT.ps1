# Launch App Window Only - Hide PowerShell Windows

Write-Host "Starting backend server (hidden)..." -ForegroundColor Gray

# Start backend in minimized window
$backendScript = @"
cd '$PWD\backend'
npm run dev
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript -WindowStyle Minimized

# Wait a few seconds for backend to start
Start-Sleep -Seconds 5

Write-Host "Launching application (app window will appear)..." -ForegroundColor Gray

# Launch Flutter app - this will show the app window, but we'll minimize PowerShell
if (Test-Path "flutter_windows\flutter\bin\flutter.bat") {
    $flutterPath = "$PWD\flutter_windows\flutter\bin\flutter.bat"
} else {
    $flutterPath = "flutter"
}

# Start Flutter - the app window will appear, PowerShell will be minimized
$process = Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; & '$flutterPath' run -d windows" -WindowStyle Minimized -PassThru

# Wait a moment then minimize the PowerShell window
Start-Sleep -Seconds 2

# Try to minimize the PowerShell window if possible
try {
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            public static readonly int SW_MINIMIZE = 6;
        }
"@
    $null = [Win32]::ShowWindow($process.MainWindowHandle, [Win32]::SW_MINIMIZE)
} catch {
    # Ignore if minimization fails
}

Write-Host ""
Write-Host "✅ Application launching!" -ForegroundColor Green
Write-Host "   - Backend: Running (hidden)" -ForegroundColor Gray
Write-Host "   - App: Starting (window will appear)" -ForegroundColor Gray
Write-Host ""
Write-Host "The app window will appear in 2-3 minutes" -ForegroundColor Yellow
Write-Host "PowerShell windows are minimized" -ForegroundColor Yellow




