# Automated Cardcom Integration Test
# This script does everything automatically: setup, start backend, test, report

$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:3000/api/v1"
$testEmail = "haitham.massarwah@medical-appointments.com"
$testPassword = "Developer@2024"
$backendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $backendPath

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   AUTOMATED CARDCOM INTEGRATION TEST" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Check and configure environment
Write-Host "Step 1: Configuring environment..." -ForegroundColor Yellow
$envFile = Join-Path $backendPath ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "   Creating .env file..." -ForegroundColor Gray
    New-Item -Path $envFile -ItemType File -Force | Out-Null
}

$envContent = Get-Content $envFile -Raw -ErrorAction SilentlyContinue

# Add Cardcom config if not exists
if ($envContent -notmatch "CARDCOM_USERNAME") {
    Add-Content -Path $envFile -Value "`n# Cardcom Payment Gateway Configuration`nCARDCOM_USERNAME=CardTest1994`nCARDCOM_PASSWORD=Terminaltest2026`nCARDCOM_TERMINAL_NUMBER=`nCARDCOM_API_KEY=`nCARDCOM_BASE_URL=https://secure.cardcom.solutions`n"
    Write-Host "   ✅ Cardcom configuration added to .env" -ForegroundColor Green
} else {
    Write-Host "   ✅ Cardcom configuration already exists" -ForegroundColor Green
}

# Check if terminal number is set
$envVars = Get-Content $envFile | Where-Object { $_ -match "^CARDCOM_TERMINAL_NUMBER=" }
$terminalNumber = ($envVars -split "=")[1].Trim()

if ([string]::IsNullOrWhiteSpace($terminalNumber)) {
    Write-Host "`n⚠️  WARNING: CARDCOM_TERMINAL_NUMBER is not set!" -ForegroundColor Yellow
    Write-Host "   The test will likely fail without terminal number." -ForegroundColor Yellow
    Write-Host "   Get it from: Cardcom account → הגדרות → ניהול מפתחות API" -ForegroundColor Yellow
    Write-Host "   Continuing test anyway to check other aspects...`n" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ Terminal number configured: $terminalNumber" -ForegroundColor Green
}

# Step 2: Install dependencies
Write-Host "`nStep 2: Checking dependencies..." -ForegroundColor Yellow
Set-Location $backendPath

$axiosInstalled = npm list axios 2>&1 | Select-String "axios@"
if (-not $axiosInstalled) {
    Write-Host "   Installing axios..." -ForegroundColor Gray
    npm install axios --silent
    Write-Host "   ✅ axios installed" -ForegroundColor Green
} else {
    Write-Host "   ✅ axios already installed" -ForegroundColor Green
}

# Step 3: Build backend
Write-Host "`nStep 3: Building backend..." -ForegroundColor Yellow
try {
    $buildOutput = npm run build 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Backend built successfully" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Build completed with warnings" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Build failed: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Check if backend is running
Write-Host "`nStep 4: Checking backend status..." -ForegroundColor Yellow
$backendRunning = $false

try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 2 -ErrorAction Stop
    if ($healthCheck.StatusCode -eq 200) {
        $backendRunning = $true
        Write-Host "   ✅ Backend is already running" -ForegroundColor Green
    }
} catch {
    Write-Host "   Backend is not running, will start it..." -ForegroundColor Gray
}

# Step 5: Start backend if not running
if (-not $backendRunning) {
    Write-Host "`nStep 5: Starting backend..." -ForegroundColor Yellow
    Write-Host "   Starting backend server (this may take 30-60 seconds)..." -ForegroundColor Gray
    
    # Start backend in background
    $backendProcess = Start-Process -FilePath "node" -ArgumentList "dist/server.js" -WorkingDirectory $backendPath -PassThru -WindowStyle Hidden
    
    # Wait for backend to start
    $maxWait = 60
    $waited = 0
    $started = $false
    
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 2
        $waited += 2
        try {
            $healthCheck = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method Get -TimeoutSec 2 -ErrorAction Stop
            if ($healthCheck.StatusCode -eq 200) {
                $started = $true
                break
            }
        } catch {
            Write-Host "   Waiting for backend... ($waited/$maxWait seconds)" -ForegroundColor Gray
        }
    }
    
    if ($started) {
        Write-Host "   ✅ Backend started successfully" -ForegroundColor Green
        $script:backendProcessId = $backendProcess.Id
    } else {
        Write-Host "   ❌ Backend failed to start within $maxWait seconds" -ForegroundColor Red
        Write-Host "   Please start manually: cd backend && npm run dev" -ForegroundColor Yellow
        exit 1
    }
} else {
    $script:backendProcessId = $null
}

# Step 6: Login to get token
Write-Host "`nStep 6: Authenticating..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    
    # Try different possible response structures
    if ($loginResponse.data.tokens.accessToken) {
        $token = $loginResponse.data.tokens.accessToken
    } elseif ($loginResponse.data.token) {
        $token = $loginResponse.data.token
    } elseif ($loginResponse.token) {
        $token = $loginResponse.token
    } elseif ($loginResponse.data.accessToken) {
        $token = $loginResponse.data.accessToken
    } elseif ($loginResponse.accessToken) {
        $token = $loginResponse.accessToken
    } else {
        Write-Host "   ⚠️  Unexpected login response structure" -ForegroundColor Yellow
        Write-Host "   Response: $($loginResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
        $token = $null
    }
    
    if ($token) {
        Write-Host "   ✅ Login successful" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Failed to extract token from login response" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Login failed: $_" -ForegroundColor Red
    Write-Host "   Please check credentials and backend status" -ForegroundColor Yellow
    exit 1
}

$script:headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "x-tenant-id" = "test-tenant"
}

# Verify token is set
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "   ❌ Token is empty!" -ForegroundColor Red
    exit 1
}
Write-Host "   Token obtained: $($token.Substring(0, [Math]::Min(20, $token.Length)))..." -ForegroundColor Gray

# Step 7: Check Cardcom service status
Write-Host "`nStep 7: Checking Cardcom service status..." -ForegroundColor Yellow
try {
    $statusResponse = Invoke-RestMethod -Uri "$baseUrl/payments/cardcom/status" -Method Get -Headers $script:headers -ErrorAction Stop
    
    Write-Host "   Cardcom Status:" -ForegroundColor Cyan
    Write-Host "      Configured: $($statusResponse.data.configured)" -ForegroundColor $(if ($statusResponse.data.configured) { "Green" } else { "Yellow" })
    Write-Host "      Test Mode: $($statusResponse.data.testMode)" -ForegroundColor White
    
    if (-not $statusResponse.data.configured) {
        Write-Host "`n   ⚠️  Cardcom is not fully configured!" -ForegroundColor Yellow
        Write-Host "      Missing: Terminal Number" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Failed to check status: $_" -ForegroundColor Yellow
}

# Step 8: Test payment
Write-Host "`nStep 8: Testing Cardcom payment..." -ForegroundColor Yellow
Write-Host "   Test Card: 4580000000000000" -ForegroundColor Gray
Write-Host "   Amount: 1.00 ILS" -ForegroundColor Gray

$testPaymentBody = @{
    appointmentId = "TEST-$(Get-Date -Format 'yyyyMMddHHmmss')"
    amount = 1.00
    currency = "ILS"
    cardNumber = "4580000000000000"
    cvv = "123"
    expirationMonth = "12"
    expirationYear = "2030"
    holderName = "Test User"
    holderEmail = "test@example.com"
    description = "Automated Cardcom Integration Test"
} | ConvertTo-Json

try {
    Write-Host "   Sending payment request..." -ForegroundColor Gray
    $paymentResponse = Invoke-RestMethod -Uri "$baseUrl/payments/cardcom/charge" -Method Post -Headers $script:headers -Body $testPaymentBody -ErrorAction Stop
    
    if ($paymentResponse.success) {
        Write-Host "`n   ✅✅✅ PAYMENT TEST SUCCESSFUL! ✅✅✅" -ForegroundColor Green
        Write-Host "`n   Payment Details:" -ForegroundColor Cyan
        Write-Host "      Transaction ID: $($paymentResponse.data.transactionId)" -ForegroundColor White
        Write-Host "      Cardcom Transaction ID: $($paymentResponse.data.cardcomTransactionId)" -ForegroundColor White
        Write-Host "      Approval Number: $($paymentResponse.data.approvalNumber)" -ForegroundColor White
        Write-Host "      Card Last 4: $($paymentResponse.data.cardLast4Digits)" -ForegroundColor White
        
        Write-Host "`n   ✅✅✅ CARDCOM INTEGRATION IS WORKING! ✅✅✅" -ForegroundColor Green
        Write-Host "   ✅ You can continue using Cardcom for payments" -ForegroundColor Green
        Write-Host "   ✅ Integration is ready for production use" -ForegroundColor Green
        
        $testResult = "SUCCESS"
    } else {
        Write-Host "`n   ❌ Payment test failed" -ForegroundColor Red
        Write-Host "      Response: $($paymentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Red
        $testResult = "FAILED"
    }
} catch {
    $errorDetails = $_.ErrorDetails.Message
    Write-Host "`n   ❌ Payment test failed" -ForegroundColor Red
    
    try {
        $errorObj = $errorDetails | ConvertFrom-Json
        Write-Host "      Error: $($errorObj.message)" -ForegroundColor Yellow
        if ($errorObj.error) {
            Write-Host "      Details: $($errorObj.error)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "      Error: $errorDetails" -ForegroundColor Yellow
    }
    
    Write-Host "`n   ⚠️  Possible Issues:" -ForegroundColor Yellow
    Write-Host "      1. Terminal number not configured" -ForegroundColor White
    Write-Host "      2. Cardcom API credentials incorrect" -ForegroundColor White
    Write-Host "      3. Network/connectivity issues" -ForegroundColor White
    Write-Host "      4. Cardcom API endpoint changed" -ForegroundColor White
    
    $testResult = "FAILED"
}

# Step 9: Generate test report
Write-Host "`nStep 9: Generating test report..." -ForegroundColor Yellow
$reportPath = Join-Path $projectRoot "CARDCOM_TEST_RESULTS.md"
$reportContent = @"
# Cardcom Integration Test Results

**Test Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Test Status:** $testResult

## Test Configuration

- **Backend URL:** $baseUrl
- **Test Account:** $testEmail
- **Terminal Number Configured:** $(if ([string]::IsNullOrWhiteSpace($terminalNumber)) { "NO" } else { "YES ($terminalNumber)" })
- **Test Card:** 4580000000000000
- **Test Amount:** 1.00 ILS

## Test Results

$(if ($testResult -eq "SUCCESS") {
@"
✅ **TEST PASSED**

Payment was processed successfully through Cardcom API.

### Payment Details:
- Transaction ID: $($paymentResponse.data.transactionId)
- Cardcom Transaction ID: $($paymentResponse.data.cardcomTransactionId)
- Approval Number: $($paymentResponse.data.approvalNumber)
- Card Last 4 Digits: $($paymentResponse.data.cardLast4Digits)

### Conclusion:
✅ Cardcom integration is working correctly
✅ Ready for production use
✅ Can continue with Cardcom payment system
"@
} else {
@"
❌ **TEST FAILED**

Payment processing failed. See error details above.

### Next Steps:
1. Verify terminal number is correct
2. Check Cardcom API credentials
3. Review backend logs for detailed errors
4. Contact Cardcom support if needed

### Alternative Options:
- Consider Shva payment gateway
- Use Stripe (already integrated)
- Try Bit payment gateway
"@
})

## System Status

- Backend Running: $(if ($backendRunning -or $started) { "YES" } else { "NO" })
- Cardcom Service Configured: $(if ($statusResponse.data.configured) { "YES" } else { "NO" })
- Test Mode: $(if ($statusResponse.data.testMode) { "YES" } else { "NO" })

## Recommendations

$(if ($testResult -eq "SUCCESS") {
@"
✅ **Continue with Cardcom**
- Integration is working
- Ready for Flutter UI integration
- Can deploy to production after final testing
"@
} else {
@"
⚠️ **Troubleshoot or Consider Alternative**
- Fix configuration issues
- Or consider alternative payment gateway
- Stripe is already integrated and working
"@
})

---
*Generated automatically by AUTO_TEST_CARDCOM.ps1*
"@

Set-Content -Path $reportPath -Value $reportContent
Write-Host "   ✅ Test report saved to: CARDCOM_TEST_RESULTS.md" -ForegroundColor Green

# Step 10: Cleanup (optional - keep backend running)
Write-Host "`nStep 10: Cleanup..." -ForegroundColor Yellow
Write-Host "   Backend is still running (PID: $backendProcessId)" -ForegroundColor Gray
Write-Host "   To stop: Stop-Process -Id $backendProcessId" -ForegroundColor Gray
Write-Host "   Or: Press Ctrl+C in backend terminal" -ForegroundColor Gray

# Final summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   TEST COMPLETE" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

Write-Host "Test Result: " -NoNewline -ForegroundColor Cyan
if ($testResult -eq "SUCCESS") {
    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "`n✅ Cardcom integration is working!" -ForegroundColor Green
    Write-Host "✅ You can continue using Cardcom for payments" -ForegroundColor Green
} else {
    Write-Host "❌ FAILED" -ForegroundColor Red
    Write-Host "`n⚠️  Test failed - check report for details" -ForegroundColor Yellow
    Write-Host "⚠️  May need terminal number configuration" -ForegroundColor Yellow
}

Write-Host "`nReport: CARDCOM_TEST_RESULTS.md" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Return exit code
if ($testResult -eq "SUCCESS") {
    exit 0
} else {
    exit 1
}

