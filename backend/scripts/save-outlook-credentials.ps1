# Save Outlook Calendar OAuth Credentials
# Run this after creating app registration in Azure Portal

# Bypass execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null

Write-Host "🔷 Save Outlook Calendar Credentials" -ForegroundColor Cyan
Write-Host ""

Write-Host "Enter your Outlook OAuth credentials:" -ForegroundColor Yellow
Write-Host ""

$clientId = Read-Host "Outlook Client ID (Application ID)"
$clientSecret = Read-Host "Outlook Client Secret" -AsSecureString
$clientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)
)

Write-Host ""
Write-Host "Updating configuration files..." -ForegroundColor Cyan

# Update development config
$devConfigPath = Join-Path $PSScriptRoot "..\config\development.config.json"
if (Test-Path $devConfigPath) {
    $devConfig = Get-Content $devConfigPath -Raw | ConvertFrom-Json
    $devConfig.calendar.outlook.clientId = $clientId
    $devConfig.calendar.outlook.clientSecret = $clientSecretPlain
    $devConfig.calendar.outlook.redirectUri = "http://localhost:3000/api/v1/calendar/outlook/callback"
    $devConfig | ConvertTo-Json -Depth 10 | Set-Content $devConfigPath
    Write-Host "✅ Updated: $devConfigPath" -ForegroundColor Green
}

# Update production config
$prodConfigPath = Join-Path $PSScriptRoot "..\config\production.config.json"
if (Test-Path $prodConfigPath) {
    $prodConfig = Get-Content $prodConfigPath -Raw | ConvertFrom-Json
    $prodConfig.calendar.outlook.clientId = $clientId
    $prodConfig.calendar.outlook.clientSecret = $clientSecretPlain
    $prodConfig.calendar.outlook.redirectUri = "https://api.medical-appointments.com/api/v1/calendar/outlook/callback"
    $prodConfig | ConvertTo-Json -Depth 10 | Set-Content $prodConfigPath
    Write-Host "✅ Updated: $prodConfigPath" -ForegroundColor Green
}

# Update .env file
$envPath = Join-Path $PSScriptRoot "..\.env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    
    # Remove old Outlook credentials if they exist
    $envContent = $envContent -replace "(?m)^OUTLOOK_CLIENT_ID=.*$", ""
    $envContent = $envContent -replace "(?m)^OUTLOOK_CLIENT_SECRET=.*$", ""
    $envContent = $envContent -replace "(?m)^OUTLOOK_REDIRECT_URI=.*$", ""
    
    # Add new credentials
    $envContent += "`n# Outlook Calendar OAuth Configuration`n"
    $envContent += "OUTLOOK_CLIENT_ID=$clientId`n"
    $envContent += "OUTLOOK_CLIENT_SECRET=$clientSecretPlain`n"
    $envContent += "OUTLOOK_REDIRECT_URI=http://localhost:3000/api/v1/calendar/outlook/callback`n"
    
    Set-Content $envPath $envContent
    Write-Host "✅ Updated: $envPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Credentials saved to config files!" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Don't forget to update .env file on server:" -ForegroundColor Yellow
Write-Host "   OUTLOOK_CLIENT_ID=$clientId" -ForegroundColor White
Write-Host "   OUTLOOK_CLIENT_SECRET=$clientSecretPlain" -ForegroundColor White
Write-Host "   OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback" -ForegroundColor White
Write-Host ""
Write-Host "🔄 Restart server to load new credentials:" -ForegroundColor Cyan
Write-Host "   Press rs in nodemon terminal" -ForegroundColor White
Write-Host "   Or: .\START_SIMPLE.bat" -ForegroundColor White
