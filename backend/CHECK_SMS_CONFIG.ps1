# Quick SMS Configuration Check

$backendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $backendPath ".env"

Write-Host "`nSMS Configuration Check..." -ForegroundColor Cyan

if (Test-Path $envFile) {
    $envContent = Get-Content $envFile -Raw
    
    $accountSid = ($envContent | Select-String -Pattern "TWILIO_ACCOUNT_SID=([^\r\n]+)").Matches.Groups[1].Value
    $authToken = ($envContent | Select-String -Pattern "TWILIO_AUTH_TOKEN=([^\r\n]+)").Matches.Groups[1].Value
    $phoneNumber = ($envContent | Select-String -Pattern "TWILIO_PHONE_NUMBER=([^\r\n]+)").Matches.Groups[1].Value
    
    Write-Host "`nTwilio Configuration:" -ForegroundColor Yellow
    Write-Host "   Account SID: $(if ($accountSid) { '✅ Set' } else { '❌ Missing' })" -ForegroundColor $(if ($accountSid) { "Green" } else { "Red" })
    Write-Host "   Auth Token: $(if ($authToken) { '✅ Set' } else { '❌ Missing' })" -ForegroundColor $(if ($authToken) { "Green" } else { "Red" })
    Write-Host "   Phone Number: $(if ($phoneNumber -and $phoneNumber -ne '') { "✅ $phoneNumber" } else { '❌ Not Set' })" -ForegroundColor $(if ($phoneNumber -and $phoneNumber -ne '') { "Green" } else { "Yellow" })
    
    if ($accountSid -and $authToken -and $phoneNumber -and $phoneNumber -ne "") {
        Write-Host "`n✅ SMS Service is configured!" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  SMS Service needs configuration" -ForegroundColor Yellow
        Write-Host "   Run: .\SETUP_SMS.ps1" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
}

