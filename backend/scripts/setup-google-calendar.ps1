# Google Calendar OAuth Setup Script
# This script helps automate Google Calendar API setup

Write-Host "🔵 Google Calendar OAuth Setup" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is installed
$gcloudInstalled = Get-Command gcloud -ErrorAction SilentlyContinue

if (-not $gcloudInstalled) {
    Write-Host "⚠️  Google Cloud CLI (gcloud) not found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To automate setup, install Google Cloud CLI:" -ForegroundColor Yellow
    Write-Host "  https://cloud.google.com/sdk/docs/install" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Or follow manual steps in: GOOGLE_CALENDAR_SETUP_STEP_BY_STEP.md" -ForegroundColor Yellow
    Write-Host ""
    exit
}

Write-Host "✅ Google Cloud CLI found!" -ForegroundColor Green
Write-Host ""

# Check if logged in
Write-Host "Checking authentication..."
$authStatus = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null

if (-not $authStatus) {
    Write-Host "⚠️  Not logged in to Google Cloud." -ForegroundColor Yellow
    Write-Host "Logging in..." -ForegroundColor Yellow
    gcloud auth login
} else {
    Write-Host "✅ Logged in as: $authStatus" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Enable Google Calendar API"
Write-Host "2. Configure OAuth consent screen"
Write-Host "3. Create OAuth credentials"
Write-Host ""
Write-Host "Would you like to continue? (Y/N)"
$continue = Read-Host

if ($continue -ne "Y" -and $continue -ne "y") {
    Write-Host "Setup cancelled."
    exit
}

# Enable Calendar API
Write-Host ""
Write-Host "Enabling Google Calendar API..." -ForegroundColor Cyan
gcloud services enable calendar-json.googleapis.com

Write-Host ""
Write-Host "✅ Google Calendar API enabled!" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  OAuth consent screen and credentials must be configured manually:" -ForegroundColor Yellow
Write-Host "   See: GOOGLE_CALENDAR_SETUP_STEP_BY_STEP.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "After creating OAuth credentials, run:" -ForegroundColor Cyan
Write-Host "  .\scripts\save-google-credentials.ps1" -ForegroundColor White

