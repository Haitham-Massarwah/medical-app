# Cardcom Payment Integration Test Script
# Tests Cardcom payment processing with test credentials

$baseUrl = "http://localhost:3000/api/v1"
$testEmail = "haitham.massarwah@medical-appointments.com"
$testPassword = "Developer@2024"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   Cardcom Payment Integration Test" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Login to get token
Write-Host "Step 1: Logging in..." -ForegroundColor Yellow
$loginBody = @{
    email = $testEmail
    password = $testPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "✅ Login successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $_" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
    "x-tenant-id" = "test-tenant"
}

# Step 2: Check Cardcom service status
Write-Host "`nStep 2: Checking Cardcom service status..." -ForegroundColor Yellow
try {
    $statusResponse = Invoke-RestMethod -Uri "$baseUrl/payments/cardcom/status" -Method Get -Headers $headers
    Write-Host "✅ Cardcom Status:" -ForegroundColor Green
    Write-Host "   Configured: $($statusResponse.data.configured)" -ForegroundColor White
    Write-Host "   Test Mode: $($statusResponse.data.testMode)" -ForegroundColor White
    
    if (-not $statusResponse.data.configured) {
        Write-Host "`n⚠️  WARNING: Cardcom is not fully configured!" -ForegroundColor Yellow
        Write-Host "   Please set the following environment variables:" -ForegroundColor Yellow
        Write-Host "   - CARDCOM_USERNAME" -ForegroundColor White
        Write-Host "   - CARDCOM_PASSWORD" -ForegroundColor White
        Write-Host "   - CARDCOM_TERMINAL_NUMBER" -ForegroundColor White
        Write-Host "   - CARDCOM_API_KEY (optional)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Failed to check status: $_" -ForegroundColor Red
}

# Step 3: Test payment with test card
Write-Host "`nStep 3: Testing payment with Cardcom test card..." -ForegroundColor Yellow
Write-Host "   Test Card: 4580000000000000" -ForegroundColor White
Write-Host "   Expiry: 12/30" -ForegroundColor White
Write-Host "   Amount: 1.00 ILS" -ForegroundColor White

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
    description = "Cardcom Integration Test"
} | ConvertTo-Json

try {
    Write-Host "`nSending payment request..." -ForegroundColor Cyan
    $paymentResponse = Invoke-RestMethod -Uri "$baseUrl/payments/cardcom/charge" -Method Post -Headers $headers -Body $testPaymentBody
    
    if ($paymentResponse.success) {
        Write-Host "`n✅ Payment Test SUCCESSFUL!" -ForegroundColor Green
        Write-Host "`nPayment Details:" -ForegroundColor Cyan
        Write-Host "   Transaction ID: $($paymentResponse.data.transactionId)" -ForegroundColor White
        Write-Host "   Cardcom Transaction ID: $($paymentResponse.data.cardcomTransactionId)" -ForegroundColor White
        Write-Host "   Approval Number: $($paymentResponse.data.approvalNumber)" -ForegroundColor White
        Write-Host "   Card Last 4 Digits: $($paymentResponse.data.cardLast4Digits)" -ForegroundColor White
        Write-Host "`n✅ Cardcom integration is working correctly!" -ForegroundColor Green
        Write-Host "   You can continue using Cardcom for payments." -ForegroundColor Green
    } else {
        Write-Host "`n❌ Payment Test FAILED" -ForegroundColor Red
        Write-Host "   Response: $($paymentResponse | ConvertTo-Json -Depth 3)" -ForegroundColor Red
    }
} catch {
    Write-Host "`n❌ Payment Test FAILED" -ForegroundColor Red
    $errorDetails = $_.ErrorDetails.Message
    Write-Host "   Error: $errorDetails" -ForegroundColor Red
    
    # Try to parse error response
    try {
        $errorObj = $errorDetails | ConvertFrom-Json
        if ($errorObj.message) {
            Write-Host "   Message: $($errorObj.message)" -ForegroundColor Yellow
        }
        if ($errorObj.error) {
            Write-Host "   Details: $($errorObj.error)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Full Error: $errorDetails" -ForegroundColor Yellow
    }
    
    Write-Host "`n⚠️  Possible Issues:" -ForegroundColor Yellow
    Write-Host "   1. Cardcom credentials not configured" -ForegroundColor White
    Write-Host "   2. Terminal number missing" -ForegroundColor White
    Write-Host "   3. API endpoint incorrect" -ForegroundColor White
    Write-Host "   4. Network/connectivity issues" -ForegroundColor White
    Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Check Cardcom API credentials in test user account" -ForegroundColor White
    Write-Host "   2. Verify terminal number is set" -ForegroundColor White
    Write-Host "   3. Check backend logs for detailed error messages" -ForegroundColor White
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   Test Complete" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

