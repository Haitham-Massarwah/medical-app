# Check OneDrive Sync Status and Connected Devices
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OneDrive Sync & Device Status Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check OneDrive sync status
Write-Host "[INFO] Checking OneDrive Sync Status..." -ForegroundColor Yellow
Write-Host ""

$oneDrivePath = $env:OneDrive
$currentPath = Get-Location

if ($oneDrivePath) {
    Write-Host "[OK] OneDrive is configured" -ForegroundColor Green
    Write-Host "   Path: $oneDrivePath" -ForegroundColor Gray
    Write-Host ""
    
    if ($currentPath.Path -like "*OneDrive*") {
        Write-Host "[OK] Current folder is synced with OneDrive!" -ForegroundColor Green
        Write-Host "   Location: $currentPath" -ForegroundColor Gray
        Write-Host ""
        Write-Host "This means:" -ForegroundColor Cyan
        Write-Host "   - Files sync automatically to all devices" -ForegroundColor Gray
        Write-Host "   - Test scripts will be available on other device" -ForegroundColor Gray
        Write-Host "   - Just wait for sync, then run scripts on other device" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "[WARNING] Current folder is NOT in OneDrive" -ForegroundColor Yellow
        Write-Host "   To sync to other device, move project to OneDrive folder" -ForegroundColor Gray
    }
} else {
    Write-Host "[ERROR] OneDrive not configured" -ForegroundColor Red
}

Write-Host ""

# Check OneDrive process
Write-Host "[INFO] Checking OneDrive Process..." -ForegroundColor Yellow
Write-Host ""

try {
    $onedriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
    if ($onedriveProcess) {
        Write-Host "[OK] OneDrive is running" -ForegroundColor Green
        Write-Host "   Process ID: $($onedriveProcess.Id)" -ForegroundColor Gray
    } else {
        Write-Host "[WARNING] OneDrive process not found" -ForegroundColor Yellow
        Write-Host "   May still sync in background, check system tray icon" -ForegroundColor Gray
    }
} catch {
    Write-Host "[INFO] Could not check OneDrive process" -ForegroundColor Gray
}

Write-Host ""

# Check network devices
Write-Host "[INFO] Checking Network Devices..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Other devices on your network:" -ForegroundColor Cyan

try {
    $devices = Get-NetNeighbor | Where-Object { $_.State -eq "Reachable" -or $_.State -eq "Stale" } | Select-Object IPAddress, LinkLayerAddress -Unique
    
    if ($devices) {
        $count = 0
        foreach ($device in $devices) {
            if ($device.IPAddress) {
                $count++
                Write-Host "   Device $count : $($device.IPAddress)" -ForegroundColor Gray
            }
        }
        if ($count -gt 0) {
            Write-Host ""
            Write-Host "Note: These devices might be able to connect to your server" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   No devices detected (or need admin rights)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   (Requires admin rights to scan network)" -ForegroundColor Yellow
}

Write-Host ""

# Check test scripts
Write-Host "[INFO] Checking if Test Scripts Exist..." -ForegroundColor Yellow
Write-Host ""

$testScripts = @("TEST_ON_THIS_DEVICE.ps1", "AUTO_RUN_TESTS_ON_OTHER_DEVICE.ps1", "RUN_TESTS_ON_OTHER_DEVICE.bat")
$foundCount = 0

foreach ($script in $testScripts) {
    if (Test-Path $script) {
        Write-Host "[OK] Found: $script" -ForegroundColor Green
        $foundCount++
    } else {
        Write-Host "[MISSING] $script" -ForegroundColor Red
    }
}

Write-Host ""

if ($foundCount -eq $testScripts.Count) {
    Write-Host "[OK] All test scripts are ready!" -ForegroundColor Green
} elseif ($foundCount -gt 0) {
    Write-Host "[WARNING] Some test scripts found ($foundCount of $($testScripts.Count))" -ForegroundColor Yellow
} else {
    Write-Host "[ERROR] Test scripts not found" -ForegroundColor Red
}

Write-Host ""

if ($currentPath.Path -like "*OneDrive*") {
    Write-Host "[OK] Files will sync to other device automatically!" -ForegroundColor Green
    Write-Host ""
    Write-Host "On your other device:" -ForegroundColor Cyan
    Write-Host "   1. Wait for OneDrive sync (check OneDrive icon in system tray)" -ForegroundColor White
    Write-Host "   2. Navigate to same folder on other device" -ForegroundColor White
    Write-Host "   3. Run: .\AUTO_RUN_TESTS_ON_OTHER_DEVICE.ps1" -ForegroundColor White
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($currentPath.Path -like "*OneDrive*") {
    Write-Host "[OK] BEST APPROACH:" -ForegroundColor Green
    Write-Host "   1. Files are syncing via OneDrive" -ForegroundColor White
    Write-Host "   2. Test scripts will appear on other device automatically" -ForegroundColor White
    Write-Host "   3. Just wait for sync, then run on other device" -ForegroundColor White
    Write-Host ""
    Write-Host "   Check OneDrive sync status in system tray icon" -ForegroundColor Yellow
    Write-Host "   Green checkmark = Synced | Cloud icon = Syncing/Not synced" -ForegroundColor Gray
} else {
    Write-Host "[INFO] MANUAL APPROACH:" -ForegroundColor Yellow
    Write-Host "   1. Copy test scripts to other device (USB/email)" -ForegroundColor White
    Write-Host "   2. Run scripts on other device" -ForegroundColor White
    Write-Host ""
    Write-Host "   OR move project to OneDrive folder for auto-sync" -ForegroundColor Cyan
}

Write-Host ""
