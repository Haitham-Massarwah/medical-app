# Update Twilio Phone Number in .env
$envFile = Join-Path $PSScriptRoot ".env"
$phoneNumber = "+15206368371"

Write-Host "Updating Twilio phone number..." -ForegroundColor Cyan

if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw
    
    # Remove old TWILIO_PHONE_NUMBER line
    $lines = Get-Content $envFile | Where-Object { $_ -notmatch "^TWILIO_PHONE_NUMBER=" }
    
    # Add new phone number
    $newContent = ($lines | Where-Object { $_ -ne "" }) -join "`n"
    $newContent += "`nTWILIO_PHONE_NUMBER=$phoneNumber`n"
    
    Set-Content -Path $envFile -Value $newContent
    Write-Host "✅ Phone number updated: $phoneNumber" -ForegroundColor Green
    
    # Verify
    $verify = Get-Content $envFile | Select-String -Pattern "TWILIO_PHONE_NUMBER"
    Write-Host "   Verified: $verify" -ForegroundColor Gray
} else {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
}

