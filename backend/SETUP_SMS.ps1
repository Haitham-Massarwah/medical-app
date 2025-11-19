# SMS Service Setup Script
# Helps configure Twilio SMS service

$ErrorActionPreference = "Stop"
$backendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $backendPath ".env"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   SMS SERVICE SETUP" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Check current configuration
Write-Host "Step 1: Checking current configuration..." -ForegroundColor Yellow

$envContent = Get-Content $envFile -Raw -ErrorAction SilentlyContinue

$accountSid = ""
$authToken = ""
$phoneNumber = ""

if ($envContent -match "TWILIO_ACCOUNT_SID=([^\r\n]+)") {
    $accountSid = $matches[1].Trim()
    Write-Host "   ✅ Account SID: $accountSid" -ForegroundColor Green
} else {
    Write-Host "   ❌ Account SID: NOT FOUND" -ForegroundColor Red
}

if ($envContent -match "TWILIO_AUTH_TOKEN=([^\r\n]+)") {
    $authToken = $matches[1].Trim()
    Write-Host "   ✅ Auth Token: [CONFIGURED]" -ForegroundColor Green
} else {
    Write-Host "   ❌ Auth Token: NOT FOUND" -ForegroundColor Red
}

if ($envContent -match "TWILIO_PHONE_NUMBER=([^\r\n]+)") {
    $phoneNumber = $matches[1].Trim()
    if ($phoneNumber -and $phoneNumber -ne "") {
        Write-Host "   ✅ Phone Number: $phoneNumber" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Phone Number: NOT SET" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  Phone Number: NOT SET" -ForegroundColor Yellow
}

# Step 2: Get phone number if missing
if (-not $phoneNumber -or $phoneNumber -eq "") {
    Write-Host "`nStep 2: Phone number configuration..." -ForegroundColor Yellow
    Write-Host "`nTo get a Twilio phone number:" -ForegroundColor Cyan
    Write-Host "   1. Login: https://console.twilio.com" -ForegroundColor White
    Write-Host "   2. Go to: Phone Numbers → Buy a Number" -ForegroundColor White
    Write-Host "   3. Select: Israel (+972)" -ForegroundColor White
    Write-Host "   4. Choose: SMS + Voice capabilities" -ForegroundColor White
    Write-Host "   5. Purchase number" -ForegroundColor White
    
    $userInput = Read-Host "`nEnter your Twilio phone number (format: +972501234567) or press Enter to skip"
    
    if (-not [string]::IsNullOrWhiteSpace($userInput)) {
        $phoneNumber = $userInput.Trim()
        
        # Validate format
        if ($phoneNumber -match "^\+972\d{9}$") {
            Write-Host "   ✅ Valid Israeli number format" -ForegroundColor Green
            
            # Update .env file
            if ($envContent -match "TWILIO_PHONE_NUMBER=") {
                $envContent = $envContent -replace "TWILIO_PHONE_NUMBER=.*", "TWILIO_PHONE_NUMBER=$phoneNumber"
            } else {
                if (-not $envContent) { $envContent = "" }
                $envContent += "`nTWILIO_PHONE_NUMBER=$phoneNumber`n"
            }
            
            Set-Content -Path $envFile -Value $envContent
            Write-Host "   ✅ Phone number saved to .env" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Invalid format. Expected: +972501234567" -ForegroundColor Yellow
            Write-Host "   You can add it manually to .env file" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️  Phone number not provided" -ForegroundColor Yellow
        Write-Host "   Add TWILIO_PHONE_NUMBER to .env manually" -ForegroundColor Yellow
    }
}

# Step 3: Check Twilio connection
Write-Host "`nStep 3: Testing Twilio connection..." -ForegroundColor Yellow

if ($accountSid -and $authToken) {
    try {
        # Test Twilio API connection
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${accountSid}:${authToken}"))
        $headers = @{
            "Authorization" = "Basic $base64Auth"
        }
        
        $response = Invoke-RestMethod -Uri "https://api.twilio.com/2010-04-01/Accounts/$accountSid.json" -Method Get -Headers $headers -ErrorAction Stop
        
        Write-Host "   ✅ Twilio connection successful" -ForegroundColor Green
        Write-Host "   Account Status: $($response.status)" -ForegroundColor White
        
        if ($response.status -eq "active") {
            Write-Host "   ✅ Account is active" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Account status: $($response.status)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Twilio connection failed: $_" -ForegroundColor Red
        Write-Host "   Check Account SID and Auth Token" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  Cannot test - missing credentials" -ForegroundColor Yellow
}

# Step 4: Check SMS service status
Write-Host "`nStep 4: Checking SMS service status..." -ForegroundColor Yellow

if ($phoneNumber -and $phoneNumber -ne "") {
    Write-Host "   ✅ Phone number configured: $phoneNumber" -ForegroundColor Green
    Write-Host "   ✅ SMS service ready to use" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Phone number not configured" -ForegroundColor Yellow
    Write-Host "   SMS service will not work until phone number is added" -ForegroundColor Yellow
}

# Step 5: Summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   SETUP SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Configuration Status:" -ForegroundColor Yellow
Write-Host "   Account SID: $(if ($accountSid) { '✅ Configured' } else { '❌ Missing' })" -ForegroundColor $(if ($accountSid) { "Green" } else { "Red" })
Write-Host "   Auth Token: $(if ($authToken) { '✅ Configured' } else { '❌ Missing' })" -ForegroundColor $(if ($authToken) { "Green" } else { "Red" })
Write-Host "   Phone Number: $(if ($phoneNumber -and $phoneNumber -ne '') { "✅ $phoneNumber" } else { '❌ Not Set' })" -ForegroundColor $(if ($phoneNumber -and $phoneNumber -ne '') { "Green" } else { "Yellow" })

if ($phoneNumber -and $phoneNumber -ne "" -and $accountSid -and $authToken) {
    Write-Host "`n✅ SMS Service is ready!" -ForegroundColor Green
    Write-Host "   Next: Restart backend and test SMS" -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  SMS Service needs configuration" -ForegroundColor Yellow
    Write-Host "   Complete the missing items above" -ForegroundColor Gray
}

Write-Host "`nTo test SMS:" -ForegroundColor Cyan
Write-Host "   1. Restart backend: npm run dev" -ForegroundColor White
Write-Host "   2. Run: .\TEST_SMS.ps1" -ForegroundColor White
Write-Host "=========================================`n" -ForegroundColor Cyan

