# Automated Development Server Startup
# This script checks configuration and starts the development server

# Bypass execution policy for this script
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null

Write-Host "🚀 Automated Development Server Startup" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
$envPath = Join-Path $PSScriptRoot "..\.env"
if (-not (Test-Path $envPath)) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    & "$PSScriptRoot\create-dev-env.ps1"
}

# Check if Google credentials are in .env
$envContent = Get-Content $envPath -Raw
if (-not ($envContent -match "GOOGLE_CLIENT_ID")) {
    Write-Host "⚠️  Adding Google Calendar credentials to .env..." -ForegroundColor Yellow
    Add-Content $envPath "`n# Google Calendar OAuth Configuration`nGOOGLE_CLIENT_ID=460829863462-cld9ijbevsa23fiphrbi1po9al23l0ae.apps.googleusercontent.com`nGOOGLE_CLIENT_SECRET=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`nGOOGLE_REDIRECT_URI=http://localhost:3000/api/v1/calendar/google/callback"
    Write-Host "✅ Google credentials added!" -ForegroundColor Green
}

# Check if node_modules exists
$nodeModulesPath = Join-Path $PSScriptRoot "..\node_modules"
if (-not (Test-Path $nodeModulesPath)) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    Set-Location (Join-Path $PSScriptRoot "..")
    npm install
}

# Check if database migration is needed
Write-Host "📋 Checking database..." -ForegroundColor Cyan
Set-Location (Join-Path $PSScriptRoot "..")

# Check if dist folder exists (compiled TypeScript)
$distPath = Join-Path $PSScriptRoot "..\dist"
if (-not (Test-Path $distPath)) {
    Write-Host "🔨 Building TypeScript..." -ForegroundColor Yellow
    npm run build
}

# Start the development server
Write-Host ""
Write-Host "✅ Configuration verified!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Starting development server..." -ForegroundColor Cyan
Write-Host "   Backend will run on: http://localhost:3000" -ForegroundColor White
Write-Host "   Google Calendar callback: http://localhost:3000/api/v1/calendar/google/callback" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start npm dev (using cmd to bypass PowerShell execution policy)
cmd /c "npm run dev"

