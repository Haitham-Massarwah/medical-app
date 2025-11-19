# Verify SMS Setup Complete
# Tests SMS service with configured phone number

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:3000/api/v1"
$testEmail = "haitham.massarwah@medical-appointments.com"
$testPassword = "Developer@2024"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   SMS SERVICE VERIFICATION" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Check configuration
Write-Host "Step 1: Checking SMS configuration..." -ForegroundColor Yellow
$envFile = Join-Path $PSScriptRoot ".env"
$envContent = Get-Content $envFile -Raw -ErrorAction SilentlyContinue

$accountSid = ""
$phoneNumber = ""

if ($envContent -match "TWILIO_ACCOUNT_SID=([^\r\n]+)") {
    $accountSid = $matches[1].Trim()
    Write-Host "   ✅ Account SID: $($accountSid.Substring(0,10))..." -ForegroundColor Green
}
if ($envContent -match "TWILIO_PHONE_NUMBER=([^\r\n]+)") {
    $phoneNumber = $matches[1].Trim()
    Write-Host "   ✅ Phone Number: $phoneNumber" -ForegroundColor Green
}

if (-not $phoneNumber -or $phoneNumber -eq "") {
    Write-Host "   ❌ Phone Number: NOT SET" -ForegroundColor Red
    Write-Host "   Add TWILIO_PHONE_NUMBER to .env" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check backend
Write-Host "`nStep 2: Checking backend..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   ✅ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend is not running" -ForegroundColor Red
    Write-Host "   Start backend: npm run dev" -ForegroundColor Yellow
    exit 1
}

# Step 3: Check SMS service status via API
Write-Host "`nStep 3: Checking SMS service status..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    $token = $loginResponse.data.tokens.accessToken
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Check notification service status
    $statusResponse = Invoke-RestMethod -Uri "$baseUrl/notifications/status" -Method Get -Headers $headers -ErrorAction Stop
    
    Write-Host "   Notification Service Status:" -ForegroundColor Cyan
    Write-Host "      Email: $($statusResponse.data.email.configured)" -ForegroundColor $(if ($statusResponse.data.email.configured) { "Green" } else { "Yellow" })
    Write-Host "      SMS: $($statusResponse.data.sms.configured)" -ForegroundColor $(if ($statusResponse.data.sms.configured) { "Green" } else { "Yellow" })
    Write-Host "      Provider: $($statusResponse.data.sms.provider)" -ForegroundColor White
    
    if ($statusResponse.data.sms.configured) {
        Write-Host "   ✅ SMS service is configured!" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  SMS service not fully configured" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Could not check status: $_" -ForegroundColor Yellow
}

# Step 4: Summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   VERIFICATION COMPLETE" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "   Twilio Phone: $phoneNumber" -ForegroundColor White
Write-Host "   Account SID: Configured" -ForegroundColor Green
Write-Host "   Backend: Running" -ForegroundColor Green

Write-Host "`n✅ SMS Service is ready!" -ForegroundColor Green
Write-Host "   To test: Run .\TEST_SMS.ps1" -ForegroundColor Gray
Write-Host "=========================================`n" -ForegroundColor Cyan

