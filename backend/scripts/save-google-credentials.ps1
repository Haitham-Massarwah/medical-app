# Save Google Calendar OAuth Credentials
# Run this after creating OAuth credentials in Google Cloud Console

Write-Host "🔵 Save Google Calendar Credentials" -ForegroundColor Cyan
Write-Host ""

Write-Host "Enter your Google OAuth credentials:" -ForegroundColor Yellow
Write-Host ""

$clientId = Read-Host "Google Client ID"
$clientSecret = Read-Host "Google Client Secret" -AsSecureString
$clientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)
)

Write-Host ""
Write-Host "Updating configuration files..." -ForegroundColor Cyan

# Update development config
$devConfigPath = "config\development.config.json"
if (Test-Path $devConfigPath) {
    $devConfig = Get-Content $devConfigPath | ConvertFrom-Json
    $devConfig.calendar.google.clientId = $clientId
    $devConfig.calendar.google.clientSecret = $clientSecretPlain
    $devConfig.calendar.google.redirectUri = "http://localhost:3000/api/v1/calendar/google/callback"
    $devConfig | ConvertTo-Json -Depth 10 | Set-Content $devConfigPath
    Write-Host "✅ Updated: $devConfigPath" -ForegroundColor Green
}

# Update production config
$prodConfigPath = "config\production.config.json"
if (Test-Path $prodConfigPath) {
    $prodConfig = Get-Content $prodConfigPath | ConvertFrom-Json
    $prodConfig.calendar.google.clientId = $clientId
    $prodConfig.calendar.google.clientSecret = $clientSecretPlain
    $prodConfig.calendar.google.redirectUri = "https://api.medical-appointments.com/api/v1/calendar/google/callback"
    $prodConfig | ConvertTo-Json -Depth 10 | Set-Content $prodConfigPath
    Write-Host "✅ Updated: $prodConfigPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Credentials saved to config files!" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Don't forget to update .env file on server:" -ForegroundColor Yellow
Write-Host "   GOOGLE_CLIENT_ID=$clientId" -ForegroundColor White
Write-Host "   GOOGLE_CLIENT_SECRET=$clientSecretPlain" -ForegroundColor White
Write-Host "   GOOGLE_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/google/callback" -ForegroundColor White

