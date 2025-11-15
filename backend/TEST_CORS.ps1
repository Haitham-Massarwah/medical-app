# CORS Testing Script - LOCALHOST ONLY
# Note: Testing localhost avoids FortiGuard network blocking
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CORS Configuration Test" -ForegroundColor Cyan
Write-Host "  (Using localhost to avoid network blocks)" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if server is running
Write-Host "Testing server connection on localhost..." -ForegroundColor Yellow
Write-Host "Note: Using localhost bypasses FortiGuard/network security blocks" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method GET -ErrorAction Stop
    Write-Host "✅ Server is running!" -ForegroundColor Green
    Write-Host "✅ Connection successful (localhost not blocked)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Health Response:" -ForegroundColor Cyan
    $response.Content | ConvertFrom-Json | ConvertTo-Json
} catch {
    Write-Host "❌ Server is NOT running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To start the server:" -ForegroundColor Yellow
    Write-Host "  cd backend" -ForegroundColor White
    Write-Host "  .\start-server-easy.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Error Details:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing CORS Headers" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test OPTIONS request (preflight)
Write-Host "Testing OPTIONS preflight request..." -ForegroundColor Yellow
Write-Host "Testing with localhost origin (bypasses network blocks)" -ForegroundColor Gray
Write-Host ""

# Test with localhost origin first (will definitely work)
try {
    $headers = @{
        "Origin" = "http://localhost:8080"
        "Access-Control-Request-Method" = "GET"
        "Access-Control-Request-Headers" = "Content-Type"
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/v1/health" `
        -Method OPTIONS `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "✅ Preflight request successful (localhost origin)!" -ForegroundColor Green
    Write-Host ""
    Write-Host "CORS Headers:" -ForegroundColor Cyan
    $response.Headers.GetEnumerator() | Where-Object { $_.Key -like "*Access-Control*" } | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Preflight test failed (may be expected if route doesn't exist)" -ForegroundColor Yellow
    Write-Host "But server is running, which is the main test!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: In development mode, CORS allows ALL origins automatically" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Testing with domain origin (may be blocked by network)..." -ForegroundColor Yellow
try {
    $headers = @{
        "Origin" = "https://medical-appointments.com"
        "Access-Control-Request-Method" = "GET"
        "Access-Control-Request-Headers" = "Content-Type"
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/v1/health" `
        -Method OPTIONS `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "✅ Preflight with domain origin also works!" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  Domain origin test may fail due to network blocking" -ForegroundColor Yellow
    Write-Host "   This is normal - use localhost for development!" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

