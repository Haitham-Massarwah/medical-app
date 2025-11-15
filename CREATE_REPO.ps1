# Create GitHub Repository Script

$token = "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"
$repoName = "medical-app"
$username = "hitha"

Write-Host "Creating GitHub repository..." -ForegroundColor Cyan

$headers = @{
    "Authorization" = "token $token"
    "Content-Type" = "application/json"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    name = $repoName
    description = "Medical Appointment Management System - Flutter + Node.js"
    private = $false
    auto_init = $false
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body
    Write-Host "✅ Repository created successfully!" -ForegroundColor Green
    Write-Host "Repository URL: $($response.html_url)" -ForegroundColor Cyan
    
    # Push code
    Write-Host "`nPushing code to GitHub..." -ForegroundColor Cyan
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Code pushed successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Push failed. Try manually: git push -u origin main" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error creating repository: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease create repository manually:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
    Write-Host "2. Name: medical-app" -ForegroundColor White
    Write-Host "3. Click 'Create repository'" -ForegroundColor White
    Write-Host "4. Then run: git push -u origin main" -ForegroundColor White
}

