# Test Google Calendar Integration
# This script logs in and gets the Google Calendar OAuth URL

Write-Host "🧪 Testing Google Calendar Integration" -ForegroundColor Cyan
Write-Host ""

# Login
Write-Host "1. Logging in..." -ForegroundColor Yellow
$login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'

if (-not $login.data.tokens.accessToken) {
    Write-Host "❌ Login failed!" -ForegroundColor Red
    exit
}

$token = $login.data.tokens.accessToken
Write-Host "✅ Login successful!" -ForegroundColor Green
Write-Host ""

# Get Calendar Auth URL
Write-Host "2. Getting Google Calendar Auth URL..." -ForegroundColor Yellow
$headers = @{Authorization = "Bearer $token"}
$result = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/calendar/google/auth-url" `
  -Method GET `
  -Headers $headers

if ($result.success) {
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Google Calendar Auth URL:" -ForegroundColor Cyan
    Write-Host $result.data.authUrl -ForegroundColor White
    Write-Host ""
    Write-Host "📝 Instructions:" -ForegroundColor Yellow
    Write-Host "  1. Copy the URL above"
    Write-Host "  2. Open it in your browser"
    Write-Host "  3. Sign in with Google and authorize"
    Write-Host "  4. You'll be redirected back to the callback"
    Write-Host ""
    
    # Ask if user wants to open URL
    $open = Read-Host "Open URL in browser? (Y/N)"
    if ($open -eq "Y" -or $open -eq "y") {
        Start-Process $result.data.authUrl
    }
} else {
    Write-Host "❌ Failed to get auth URL!" -ForegroundColor Red
    Write-Host $result | ConvertTo-Json
}

