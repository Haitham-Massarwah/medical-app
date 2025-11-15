# Easy Server Startup Script with CORS Debugging
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Medical Appointments Backend Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to backend directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    Write-Host "📝 Creating .env from env.example..." -ForegroundColor Cyan
    
    if (Test-Path "env.example") {
        Copy-Item "env.example" ".env"
        Write-Host "✅ .env file created. Please edit it with your configuration." -ForegroundColor Green
        Write-Host ""
        Write-Host "Press any key to continue or Ctrl+C to exit and configure .env first..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "❌ env.example not found! Cannot create .env" -ForegroundColor Red
        exit 1
    }
}

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
}

# Check if database connection is configured
$envContent = Get-Content ".env" -Raw
if ($envContent -notmatch "DB_HOST=" -or $envContent -notmatch "DB_NAME=") {
    Write-Host "⚠️  Warning: Database configuration may be incomplete!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Server Configuration:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
# Get network IP for remote access
$networkIP = "Not detected"
try {
    $adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }
    if ($adapters) {
        $networkIP = $adapters[0].IPAddress
    }
} catch {
    # Fallback to ipconfig method
    $ipconfig = ipconfig | Select-String "IPv4"
    if ($ipconfig) {
        $networkIP = ($ipconfig.ToString() -split ":")[-1].Trim()
    }
}

Write-Host "📍 Server URL (Local): http://localhost:3000" -ForegroundColor White
Write-Host "🌐 Server URL (Network): http://$networkIP:3000" -ForegroundColor Cyan
Write-Host "🔗 API Base: http://$networkIP:3000/api/v1" -ForegroundColor White
Write-Host "❤️  Health Check: http://$networkIP:3000/health" -ForegroundColor White
Write-Host ""
Write-Host "📱 Access from other device:" -ForegroundColor Yellow
Write-Host "   Use: http://$networkIP:3000" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 CORS Origins:" -ForegroundColor Cyan
Write-Host "   - All origins allowed in development mode" -ForegroundColor Gray
Write-Host "   - Works from any device on network" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Development mode is VERY PERMISSIVE (allows all origins)" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Server..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Set environment variable for CORS logging if needed
$env:LOG_CORS = "false"
$env:NODE_ENV = "development"

# Start the server
npm run dev

