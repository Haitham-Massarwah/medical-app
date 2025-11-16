# Update .env with Cardcom credentials from image
$envFile = Join-Path $PSScriptRoot ".env"

Write-Host "Updating .env with Cardcom credentials..." -ForegroundColor Cyan

# Read existing content
$content = ""
if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw
} else {
    $content = ""
}

# Cardcom credentials from image
$cardcomConfig = @"
# Cardcom Payment Gateway Configuration
CARDCOM_USERNAME=CardTest1994
CARDCOM_PASSWORD=Terminaltest2026
CARDCOM_TERMINAL_NUMBER=1000
CARDCOM_API_KEY=kzFKfohEvL6AOF8aMEJz
CARDCOM_API_PASSWORD=FIDHIh4pAadw3Slbdsjg
CARDCOM_BASE_URL=https://secure.cardcom.solutions
"@

# Remove old Cardcom config
$lines = Get-Content $envFile -ErrorAction SilentlyContinue | Where-Object { 
    $_ -notmatch "^CARDCOM_" -and $_ -notmatch "^# Cardcom"
}

# Add new config
$newContent = ($lines | Where-Object { $_ -ne "" }) -join "`n"
if ($newContent) {
    $newContent += "`n`n$cardcomConfig"
} else {
    $newContent = $cardcomConfig
}

Set-Content -Path $envFile -Value $newContent

Write-Host "✅ Updated .env with:" -ForegroundColor Green
Write-Host "   Terminal Number: 1000" -ForegroundColor White
Write-Host "   API Key: kzFKfohEvL6AOF8aMEJz" -ForegroundColor White
Write-Host "   API Password: FIDHIh4pAadw3Slbdsjg" -ForegroundColor White

