# Add Cardcom environment variables to .env file

$envFile = ".env"
$cardcomConfig = @"
# Cardcom Payment Gateway Configuration
CARDCOM_USERNAME=CardTest1994
CARDCOM_PASSWORD=Terminaltest2026
CARDCOM_TERMINAL_NUMBER=
CARDCOM_API_KEY=
CARDCOM_BASE_URL=https://secure.cardcom.solutions
"@

Write-Host "Adding Cardcom configuration to .env file..." -ForegroundColor Cyan

if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw
    
    if ($content -notmatch "CARDCOM_USERNAME") {
        Add-Content -Path $envFile -Value "`n$cardcomConfig"
        Write-Host "✅ Cardcom configuration added to .env" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Cardcom configuration already exists in .env" -ForegroundColor Yellow
    }
} else {
    Set-Content -Path $envFile -Value $cardcomConfig
    Write-Host "✅ Created .env file with Cardcom configuration" -ForegroundColor Green
}

Write-Host "`n⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "   Please update CARDCOM_TERMINAL_NUMBER in .env file" -ForegroundColor White
Write-Host "   Get it from: Cardcom test account → הגדרות → ניהול מפתחות API" -ForegroundColor White

