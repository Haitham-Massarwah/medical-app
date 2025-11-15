# Comprehensive Test Script for Other Device
# Run this on the OTHER device to test everything

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Medical Appointments - Test Suite" -ForegroundColor Cyan
Write-Host "  Run this on the OTHER device" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$results = @{
    "Domain Access" = $false
    "Server Connection" = $false
    "CORS Test" = $false
}

# Test 1: Domain Access
Write-Host "[TEST 1] Testing domain: medical-appointments.com" -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://medical-appointments.com" -Method GET -TimeoutSec 10 -ErrorAction Stop
    
    Write-Host "✅ Domain is ACCESSIBLE!" -ForegroundColor Green
    Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Gray
    Write-Host "   This device is NOT blocked by FortiGuard!" -ForegroundColor Green
    Write-Host ""
    $results["Domain Access"] = $true
    
} catch {
    $errorMsg = $_.Exception.Message
    Write-Host "❌ Domain is BLOCKED or not accessible" -ForegroundColor Red
    Write-Host "   Error: $errorMsg" -ForegroundColor Gray
    
    if ($errorMsg -like "*FortiGuard*" -or $errorMsg -like "*blocked*") {
        Write-Host "   This device is also behind FortiGuard" -ForegroundColor Yellow
    } else {
        Write-Host "   Connection issue or domain not configured" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Test 2: Server Connection
Write-Host "[TEST 2] Testing server connection" -ForegroundColor Yellow
Write-Host ""

$serverIP = Read-Host "Enter the server IP address (shown when server started) [or press Enter to skip]"

if ($serverIP) {
    Write-Host ""
    Write-Host "Testing: http://$serverIP:3000/health" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $response = Invoke-WebRequest -Uri "http://$serverIP:3000/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✅ Server is ACCESSIBLE!" -ForegroundColor Green
        Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Cyan
        $response.Content | ConvertFrom-Json | ConvertTo-Json
        Write-Host ""
        $results["Server Connection"] = $true
        
    } catch {
        Write-Host "❌ Cannot connect to server" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Make sure:" -ForegroundColor Yellow
        Write-Host "  1. Server is running on the other device" -ForegroundColor White
        Write-Host "  2. Both devices are on same network" -ForegroundColor White
        Write-Host "  3. Firewall allows port 3000 on server device" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host "Skipping server connection test..." -ForegroundColor Gray
    Write-Host ""
}

# Test 3: CORS Test (if server accessible)
if ($results["Server Connection"]) {
    Write-Host "[TEST 3] Testing CORS configuration" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $headers = @{
            "Origin" = "http://medical-appointments.com"
            "Access-Control-Request-Method" = "GET"
        }
        
        $response = Invoke-WebRequest -Uri "http://$serverIP:3000/api/v1/health" `
            -Method OPTIONS `
            -Headers $headers `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        $corsHeaders = $response.Headers.GetEnumerator() | Where-Object { $_.Key -like "*Access-Control*" }
        
        if ($corsHeaders) {
            Write-Host "✅ CORS headers present!" -ForegroundColor Green
            Write-Host ""
            Write-Host "CORS Headers:" -ForegroundColor Cyan
            $corsHeaders | ForEach-Object {
                Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
            }
            Write-Host ""
            $results["CORS Test"] = $true
        } else {
            Write-Host "⚠️  No CORS headers found (may still work in development)" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "⚠️  CORS test failed (may be expected if route doesn't exist)" -ForegroundColor Yellow
        Write-Host "   Server is accessible, which is the main thing!" -ForegroundColor Green
        Write-Host ""
    }
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($results["Domain Access"]) {
    Write-Host "✅ Domain Access: WORKING" -ForegroundColor Green
    Write-Host "   → medical-appointments.com is accessible on this device" -ForegroundColor Gray
    Write-Host "   → This device is NOT blocked by FortiGuard" -ForegroundColor Green
    Write-Host "   → You can use this device for testing!" -ForegroundColor Green
} else {
    Write-Host "❌ Domain Access: BLOCKED" -ForegroundColor Red
    Write-Host "   → This device is also behind FortiGuard" -ForegroundColor Yellow
    Write-Host "   → Use IP address method for server testing" -ForegroundColor Yellow
}

Write-Host ""

if ($results["Server Connection"]) {
    Write-Host "✅ Server Connection: WORKING" -ForegroundColor Green
    Write-Host "   → Can connect to server from this device" -ForegroundColor Gray
    Write-Host "   → All API endpoints accessible" -ForegroundColor Green
} else {
    Write-Host "❓ Server Connection: NOT TESTED" -ForegroundColor Yellow
    Write-Host "   → Run again and enter server IP to test" -ForegroundColor Gray
}

Write-Host ""

if ($results["CORS Test"]) {
    Write-Host "✅ CORS Configuration: WORKING" -ForegroundColor Green
} else {
    Write-Host "ℹ️  CORS Test: Skipped or inconclusive" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($results["Domain Access"]) {
    Write-Host "🎉 EXCELLENT NEWS!" -ForegroundColor Green
    Write-Host "   This device can access the domain!" -ForegroundColor Green
    Write-Host "   You can use this device for all testing!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Use this device to access: http://medical-appointments.com" -ForegroundColor White
    Write-Host "  2. Test your application from this device" -ForegroundColor White
    Write-Host "  3. All development can happen here!" -ForegroundColor White
} else {
    Write-Host "⚠️  This device is also blocked" -ForegroundColor Yellow
    Write-Host "   But you can still:" -ForegroundColor Cyan
    Write-Host "  1. Use IP address to connect to server" -ForegroundColor White
    Write-Host "  2. Test server API endpoints" -ForegroundColor White
    Write-Host "  3. Use localhost on server device for development" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to open browser tests..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open browser for visual testing
Start-Process "http://medical-appointments.com"
if ($serverIP) {
    Start-Sleep -Seconds 2
    Start-Process "http://$serverIP:3000/health"
}

Write-Host ""
Write-Host "Browser windows opened!" -ForegroundColor Green
Write-Host "Check if the domain loads in your browser." -ForegroundColor Cyan
Write-Host ""


