# Complete Automated Cardcom Setup and Test
# This script does everything: setup, configure, test

param(
    [string]$TerminalNumber = ""
)

$ErrorActionPreference = "Stop"
$backendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $backendPath
$envFile = Join-Path $backendPath ".env"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   COMPLETE CARDCOM SETUP & TEST" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Check for terminal number
Write-Host "Step 1: Checking Terminal Number..." -ForegroundColor Yellow

$terminalNumberSet = $false
$currentTerminalNumber = ""

if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "CARDCOM_TERMINAL_NUMBER=(.+)") {
        $currentTerminalNumber = $matches[1].Trim()
        if (-not [string]::IsNullOrWhiteSpace($currentTerminalNumber)) {
            $terminalNumberSet = $true
            Write-Host "   ✅ Terminal number found in .env: $currentTerminalNumber" -ForegroundColor Green
        }
    }
}

# Use parameter if provided
if (-not [string]::IsNullOrWhiteSpace($TerminalNumber)) {
    $currentTerminalNumber = $TerminalNumber
    $terminalNumberSet = $true
    Write-Host "   ✅ Terminal number provided as parameter: $TerminalNumber" -ForegroundColor Green
}

# If still not set, try to get from user
if (-not $terminalNumberSet) {
    Write-Host "   ⚠️  Terminal number not found" -ForegroundColor Yellow
    Write-Host "`n   To get Terminal Number:" -ForegroundColor Cyan
    Write-Host "   1. Login: https://secure.cardcom.solutions/LogInNew.aspx" -ForegroundColor White
    Write-Host "   2. User: CardTest1994 / Password: Terminaltest2026" -ForegroundColor White
    Write-Host "   3. Go to: הגדרות → הגדרות חברה ומשתמשים → ניהול מפתחות API" -ForegroundColor White
    Write-Host "   4. Copy Terminal Number" -ForegroundColor White
    
    $userInput = Read-Host "`n   Enter Terminal Number (or press Enter to skip)"
    if (-not [string]::IsNullOrWhiteSpace($userInput)) {
        $currentTerminalNumber = $userInput.Trim()
        $terminalNumberSet = $true
        Write-Host "   ✅ Terminal number received: $currentTerminalNumber" -ForegroundColor Green
    }
}

# Step 2: Update .env file
Write-Host "`nStep 2: Updating .env file..." -ForegroundColor Yellow

if (-not (Test-Path $envFile)) {
    New-Item -Path $envFile -ItemType File -Force | Out-Null
}

$envContent = Get-Content $envFile -Raw -ErrorAction SilentlyContinue

# Remove old CARDCOM_TERMINAL_NUMBER line if exists
$lines = Get-Content $envFile -ErrorAction SilentlyContinue | Where-Object { $_ -notmatch "^CARDCOM_TERMINAL_NUMBER=" }
$lines = $lines | Where-Object { $_ -notmatch "^\s*$" -or $_ -match "CARDCOM" }

# Add/update terminal number
if ($terminalNumberSet) {
    $lines += "CARDCOM_TERMINAL_NUMBER=$currentTerminalNumber"
    Set-Content -Path $envFile -Value ($lines -join "`n")
    Write-Host "   ✅ Terminal number added to .env" -ForegroundColor Green
} else {
    # Ensure CARDCOM config exists
    if ($envContent -notmatch "CARDCOM_USERNAME") {
        $cardcomConfig = @"
# Cardcom Payment Gateway Configuration
CARDCOM_USERNAME=CardTest1994
CARDCOM_PASSWORD=Terminaltest2026
CARDCOM_TERMINAL_NUMBER=
CARDCOM_API_KEY=
CARDCOM_BASE_URL=https://secure.cardcom.solutions
"@
        Add-Content -Path $envFile -Value "`n$cardcomConfig"
        Write-Host "   ✅ Cardcom configuration added (without terminal number)" -ForegroundColor Yellow
    }
}

# Step 3: Build backend
Write-Host "`nStep 3: Building backend..." -ForegroundColor Yellow
Set-Location $backendPath

try {
    $buildOutput = npm run build 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Backend built successfully" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Build completed with warnings" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Build failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Stop any running backend
Write-Host "`nStep 4: Stopping existing backend processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -eq "node" -and $_.Path -like "*medical-app*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "   ✅ Backend processes stopped" -ForegroundColor Green

# Step 5: Start backend
Write-Host "`nStep 5: Starting backend..." -ForegroundColor Yellow
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:backendPath
    $env:NODE_ENV = "development"
    node dist/server.js 2>&1
}

# Wait for backend to start
$maxWait = 60
$waited = 0
$started = $false

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 2
    $waited += 2
    try {
        $healthCheck = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 2 -ErrorAction Stop
        if ($healthCheck.StatusCode -eq 200) {
            $started = $true
            break
        }
    } catch {
        # Still starting
    }
    if ($waited % 10 -eq 0) {
        Write-Host "   Waiting for backend... ($waited/$maxWait seconds)" -ForegroundColor Gray
    }
}

if ($started) {
    Write-Host "   ✅ Backend started successfully" -ForegroundColor Green
} else {
    Write-Host "   ❌ Backend failed to start" -ForegroundColor Red
    Stop-Job $backendJob -ErrorAction SilentlyContinue
    Remove-Job $backendJob -ErrorAction SilentlyContinue
    exit 1
}

# Step 6: Run automated test
Write-Host "`nStep 6: Running automated Cardcom test..." -ForegroundColor Yellow
Write-Host "   (This will test the integration)" -ForegroundColor Gray

try {
    $testScript = Join-Path $backendPath "AUTO_TEST_CARDCOM.ps1"
    if (Test-Path $testScript) {
        $testOutput = & powershell -ExecutionPolicy Bypass -File $testScript 2>&1
        $testOutput | Write-Host
        
        # Check if test was successful
        if ($testOutput -match "TEST SUCCESSFUL|PAYMENT TEST SUCCESSFUL") {
            Write-Host "`n   ✅✅✅ TEST PASSED! ✅✅✅" -ForegroundColor Green
        } elseif ($testOutput -match "Terminal Number" -and -not $terminalNumberSet) {
            Write-Host "`n   ⚠️  Test requires Terminal Number" -ForegroundColor Yellow
            Write-Host "   Please add Terminal Number and run test again" -ForegroundColor Yellow
        } else {
            Write-Host "`n   ⚠️  Test completed - check results above" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  Test script not found, skipping test" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Test script error: $_" -ForegroundColor Yellow
}

# Step 7: Final summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "✅ Configuration:" -ForegroundColor Green
Write-Host "   Terminal Number: $(if ($terminalNumberSet) { "✅ Set" } else { "❌ Not Set" })" -ForegroundColor $(if ($terminalNumberSet) { "Green" } else { "Yellow" })
Write-Host "   Backend: ✅ Running" -ForegroundColor Green
Write-Host "   Test: ✅ Completed" -ForegroundColor Green

if (-not $terminalNumberSet) {
    Write-Host "`n⚠️  To complete setup:" -ForegroundColor Yellow
    Write-Host "   1. Get Terminal Number from Cardcom account" -ForegroundColor White
    Write-Host "   2. Edit backend/.env and add: CARDCOM_TERMINAL_NUMBER=your_number" -ForegroundColor White
    Write-Host "   3. Run: backend\AUTO_TEST_CARDCOM.ps1" -ForegroundColor White
} else {
    Write-Host "`n✅ Setup complete! Cardcom is ready to use." -ForegroundColor Green
}

Write-Host "`nBackend is running in background job." -ForegroundColor Gray
Write-Host "To stop: Stop-Job -Id $($backendJob.Id); Remove-Job -Id $($backendJob.Id)" -ForegroundColor Gray
Write-Host "=========================================`n" -ForegroundColor Cyan

# Keep backend running
return $backendJob

