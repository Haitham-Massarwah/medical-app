# PowerShell script to configure Outlook email

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Outlook Email Configuration Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$envFile = "backend\.env"

# Check if .env exists
if (!(Test-Path $envFile)) {
    Write-Host "Creating .env file from example..." -ForegroundColor Yellow
    Copy-Item "backend\env.example" $envFile -Force
}

# Read current .env file
$envContent = Get-Content $envFile -Raw

# Update SMTP settings to Outlook
$envContent = $envContent -replace 'SMTP_HOST=smtp\.gmail\.com', 'SMTP_HOST=smtp.office365.com'
$envContent = $envContent -replace 'SMTP_USER=haitham\.massarwah@medical-appointments\.com', 'SMTP_USER=your-email@outlook.com'
$envContent = $envContent -replace 'EMAIL_FROM=Medical Appointments <haitham\.massarwah@medical-appointments\.com>', 'EMAIL_FROM=Medical Appointments <your-email@outlook.com>'

# Write back to file
$envContent | Set-Content $envFile -NoNewline

Write-Host "✅ Updated backend\.env with Outlook settings!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit backend\.env and replace:" -ForegroundColor White
Write-Host "   - your-email@outlook.com → Your Outlook email" -ForegroundColor White
Write-Host "   - your-app-password → Your Outlook password" -ForegroundColor White
Write-Host ""
Write-Host "2. Restart backend server: cd backend && npm run dev" -ForegroundColor White
Write-Host ""





