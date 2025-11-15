# Run Flutter Tests Script

Write-Host "🧪 Running Flutter Tests..." -ForegroundColor Cyan
Write-Host ""

$flutterPaths = @(
    "C:\flutter\bin\flutter.bat",
    "C:\src\flutter\bin\flutter.bat",
    "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
    "$env:USERPROFILE\flutter\bin\flutter.bat",
    "flutter\bin\flutter.bat"
)

$flutterFound = $false

foreach ($path in $flutterPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Found Flutter at: $path" -ForegroundColor Green
        & $path test
        $flutterFound = $true
        break
    }
}

if (-not $flutterFound) {
    Write-Host "❌ Flutter not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Flutter is installed and in your PATH" -ForegroundColor Yellow
    Write-Host "Or run: flutter test (if Flutter is in PATH)" -ForegroundColor Yellow
}

