# Test SMS Service
# Sends a test SMS to verify configuration

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:3000/api/v1"
$testEmail = "haitham.massarwah@medical-appointments.com"
$testPassword = "Developer@2024"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   SMS SERVICE TEST" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Check backend
Write-Host "Step 1: Checking backend..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "   ✅ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend is not running" -ForegroundColor Red
    Write-Host "   Start backend: npm run dev" -ForegroundColor Yellow
    exit 1
}

# Step 2: Login
Write-Host "`nStep 2: Logging in..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    $token = $loginResponse.data.tokens.accessToken
    Write-Host "   ✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Login failed: $_" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Step 3: Get phone number
Write-Host "`nStep 3: Enter phone number for test SMS..." -ForegroundColor Yellow
Write-Host "   Format: +972501234567 (with country code)" -ForegroundColor Gray
$testPhoneNumber = Read-Host "Enter phone number"

if ([string]::IsNullOrWhiteSpace($testPhoneNumber)) {
    Write-Host "   ⚠️  No phone number provided, skipping test" -ForegroundColor Yellow
    exit 0
}

# Step 4: Send test SMS
Write-Host "`nStep 4: Sending test SMS..." -ForegroundColor Yellow
Write-Host "   To: $testPhoneNumber" -ForegroundColor Gray

$smsBody = @{
    to = $testPhoneNumber
    message = "Test SMS from Medical Appointment System - If you received this, SMS service is working! ✅"
    type = "test"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/notifications/sms" -Method Post -Headers $headers -Body $smsBody -ErrorAction Stop
    
    Write-Host "`n   ✅✅✅ SMS SENT SUCCESSFULLY! ✅✅✅" -ForegroundColor Green
    Write-Host "`n   Check your phone for the test message" -ForegroundColor Cyan
    
    if ($response.success) {
        Write-Host "   Response: $($response.message)" -ForegroundColor White
    }
} catch {
    Write-Host "`n   ❌ SMS sending failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.ErrorDetails.Message) {
        try {
            $errorObj = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "   Details: $($errorObj.message)" -ForegroundColor Yellow
            
            if ($errorObj.message -match "phone number") {
                Write-Host "`n   💡 Possible Issues:" -ForegroundColor Cyan
                Write-Host "      - Phone number not verified (Trial account)" -ForegroundColor White
                Write-Host "      - Invalid phone number format" -ForegroundColor White
                Write-Host "      - TWILIO_PHONE_NUMBER not configured" -ForegroundColor White
            }
        } catch {
            Write-Host "   Raw Error: $($_.ErrorDetails.Message)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   Test Complete" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

