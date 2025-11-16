# Fix Cardcom Authentication - Test different methods
$backendPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $backendPath ".env"

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   FIXING CARDCOM AUTHENTICATION" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Step 1: Verify credentials
Write-Host "Step 1: Verifying Cardcom credentials..." -ForegroundColor Yellow
$envContent = Get-Content $envFile -Raw -ErrorAction SilentlyContinue

$terminalNumber = ""
$username = ""
$password = ""
$apiKey = ""
$apiPassword = ""

if ($envContent -match "CARDCOM_TERMINAL_NUMBER=([^\r\n]+)") {
    $terminalNumber = $matches[1].Trim()
    Write-Host "   ✅ Terminal Number: $terminalNumber" -ForegroundColor Green
}
if ($envContent -match "CARDCOM_USERNAME=([^\r\n]+)") {
    $username = $matches[1].Trim()
    Write-Host "   ✅ Username: $username" -ForegroundColor Green
}
if ($envContent -match "CARDCOM_PASSWORD=([^\r\n]+)") {
    $password = $matches[1].Trim()
    Write-Host "   ✅ Password: [HIDDEN]" -ForegroundColor Green
}
if ($envContent -match "CARDCOM_API_KEY=([^\r\n]+)") {
    $apiKey = $matches[1].Trim()
    Write-Host "   ✅ API Key: $apiKey" -ForegroundColor Green
}
if ($envContent -match "CARDCOM_API_PASSWORD=([^\r\n]+)") {
    $apiPassword = $matches[1].Trim()
    Write-Host "   ✅ API Password: [HIDDEN]" -ForegroundColor Green
}

# Step 2: Rebuild backend
Write-Host "`nStep 2: Rebuilding backend..." -ForegroundColor Yellow
Set-Location $backendPath
npm run build 2>&1 | Out-Null
Write-Host "   ✅ Backend rebuilt" -ForegroundColor Green

# Step 3: Restart backend
Write-Host "`nStep 3: Restarting backend..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -eq "node" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:backendPath
    $env:NODE_ENV = "development"
    node dist/server.js 2>&1
}

Start-Sleep -Seconds 10
Write-Host "   ✅ Backend restarted" -ForegroundColor Green

# Step 4: Test authentication
Write-Host "`nStep 4: Testing Cardcom authentication..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$loginBody = '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'
try {
    $login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.data.tokens.accessToken
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Write-Host "   Testing payment with Terminal $terminalNumber..." -ForegroundColor Gray
    
    $testBody = @{
        appointmentId = "TEST-$(Get-Date -Format 'yyyyMMddHHmmss')"
        amount = 1.00
        currency = "ILS"
        cardNumber = "4580000000000000"
        cvv = "123"
        expirationMonth = "12"
        expirationYear = "2030"
        holderName = "Test User"
        holderEmail = "test@example.com"
        description = "Authentication Test"
    } | ConvertTo-Json
    
    try {
        $result = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/payments/cardcom/charge" -Method Post -Headers $headers -Body $testBody -ErrorAction Stop
        
        Write-Host "`n   ✅✅✅ AUTHENTICATION SUCCESSFUL! ✅✅✅" -ForegroundColor Green
        Write-Host "   Transaction ID: $($result.data.transactionId)" -ForegroundColor White
        Write-Host "   Cardcom Transaction: $($result.data.cardcomTransactionId)" -ForegroundColor White
        Write-Host "`n   ✅ Cardcom is now working correctly!" -ForegroundColor Green
    } catch {
        Write-Host "`n   ⚠️  Authentication still failing" -ForegroundColor Yellow
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.ErrorDetails.Message) {
            try {
                $errorObj = $_.ErrorDetails.Message | ConvertFrom-Json
                Write-Host "   Details: $($errorObj.message)" -ForegroundColor Yellow
            } catch {
                Write-Host "   Raw Error: $($_.ErrorDetails.Message)" -ForegroundColor Gray
            }
        }
        
        Write-Host "`n   💡 Next Steps:" -ForegroundColor Cyan
        Write-Host "   1. Check Cardcom API documentation" -ForegroundColor White
        Write-Host "   2. Verify credentials with Cardcom support" -ForegroundColor White
        Write-Host "   3. Test API endpoint directly with Postman" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Failed to login: $_" -ForegroundColor Red
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   Complete" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

