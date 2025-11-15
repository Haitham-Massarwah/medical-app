# Start Backend Server Script
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Starting Medical Appointment Backend" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Change to backend directory
Set-Location $PSScriptRoot

# Start the server
Write-Host "🚀 Starting server on http://localhost:3000`n" -ForegroundColor Green
npm run dev











