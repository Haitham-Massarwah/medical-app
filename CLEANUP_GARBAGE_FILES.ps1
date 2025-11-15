# Cleanup Garbage Files Script
# This script removes temporary, duplicate, and unnecessary files from the project

Write-Host "🧹 Starting Cleanup Process..." -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Projects\medical-app"
$oneDrivePath = "C:\Users\hitha\OneDrive\Desktop\Haitham-Works\App"

# Files to delete (patterns)
$garbagePatterns = @(
    # Temporary files
    "~$*",
    "*.tmp",
    "*.temp",
    "*.log",
    "*.bak",
    "*.swp",
    "*.swo",
    "*~",
    
    # Lock files
    "*.lock",
    
    # Old flutter plugins
    "-IL-Haitam--M.flutter-plugins*",
    
    # Zip files (keep only if needed)
    "*.zip",
    
    # Documentation duplicates (keep only essential)
    "✅_*.md",
    "✅_*.txt",
    "🎉_*.md",
    "🎉_*.txt",
    "📱_*.txt",
    "🚀_*.txt",
    "▶️_*.txt",
    "⚠️_*.txt",
    "📋_*.md",
    "📥_*.md",
    "📊_*.md",
    "🎯_*.md",
    "👨‍⚕️_*.md",
    "📅_*.md",
    "🔧_*.md",
    "🌐_*.md",
    
    # Status files
    "ALL_*.md",
    "ALL_*.txt",
    "COMPLETE*.md",
    "COMPLETE*.txt",
    "FINAL*.md",
    "FINAL*.txt",
    "TODO*.md",
    "TODO*.txt",
    "STATUS*.md",
    "CURRENT*.txt",
    "NEXT*.md",
    "QUICK*.md",
    "QUICK*.txt",
    "TEST*.md",
    "TEST*.txt",
    "CHECK*.md",
    "VERIFY*.md",
    "DEBUG*.md",
    "FIX*.md",
    "FIX*.ps1",
    "FIX*.bat",
    "DEPLOY*.md",
    "SETUP*.md",
    "INSTALL*.md",
    "INSTALL*.txt",
    "HOW*.md",
    "WHAT*.md",
    "WHILE*.txt",
    "WORKING*.md",
    "PROGRESS*.md",
    "PROGRESS*.txt",
    "UPDATE*.md",
    "SUMMARY*.md",
    "SUMMARY*.txt",
    "REPORT*.md",
    "REPORT*.txt",
    "GUIDE*.md",
    "GUIDE*.txt",
    "PROTOCOL*.md",
    "PROTOCOL*.html",
    "ROADMAP*.md",
    "ROADMAP*.txt",
    "ANALYSIS*.md",
    "EVALUATION*.md",
    "CHECKLIST*.md",
    "TRACKING*.md",
    "REQUIREMENTS*.md",
    "IMPLEMENTATION*.md",
    "MIGRATION*.md",
    "CONVERSION*.md",
    "CONVERSION*.ps1",
    "CONVERSION*.bat",
    "CONVERT*.ps1",
    "CONVERT*.bat",
    "CREATE*.md",
    "CREATE*.ps1",
    "CREATE*.sql",
    "COPY*.ps1",
    "COPY*.txt",
    "DELETE*.bat",
    "OPEN*.bat",
    "SHOW*.bat",
    "SAVE*.txt",
    "SAVE*.md",
    "Website.txt",
    "Login.txt",
    "last update.txt",
    "סיכום*.txt"
)

# Essential files to KEEP
$keepFiles = @(
    "README.md",
    "pubspec.yaml",
    "pubspec.lock",
    "ENVIRONMENT.txt",
    "ENVIRONMENT_SWITCH_GUIDE.md",
    "PROJECT_STATUS_REPORT.md",
    "QUICK_SUMMARY.md",
    "WORKFLOW_GUIDE.md",
    "AUTOMATED_TASKS.md",
    "UPDATE_TASKS.ps1",
    "SYNC_TO_ONEDRIVE.ps1",
    "CLEANUP_GARBAGE_FILES.ps1",
    "docker-compose.yml",
    "main.dart",
    "lib\",
    "backend\",
    "assets\",
    "android\",
    "ios\",
    "web\",
    "windows\",
    "test\",
    "integration_test\",
    "DOCUMENTATION\",
    "CLINIC_INSTALLATION\",
    "client_secret*.json"
)

function Clean-Directory {
    param($path)
    
    if (-not (Test-Path $path)) {
        Write-Host "⚠️  Path not found: $path" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📁 Cleaning: $path" -ForegroundColor Cyan
    
    $deletedCount = 0
    $deletedSize = 0
    
    Get-ChildItem -Path $path -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $file = $_
        $shouldDelete = $false
        
        # Check if file matches garbage patterns
        foreach ($pattern in $garbagePatterns) {
            if ($file.Name -like $pattern) {
                $shouldDelete = $true
                break
            }
        }
        
        # Check if file is in keep list
        foreach ($keep in $keepFiles) {
            if ($file.FullName -like "*\$keep*") {
                $shouldDelete = $false
                break
            }
        }
        
        if ($shouldDelete) {
            try {
                $size = $file.Length
                Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
                $deletedCount++
                $deletedSize += $size
                Write-Host "  ❌ Deleted: $($file.Name)" -ForegroundColor Red
            } catch {
                Write-Host "  ⚠️  Could not delete: $($file.Name)" -ForegroundColor Yellow
            }
        }
    }
    
    $sizeMB = [math]::Round($deletedSize/1MB, 2)
    Write-Host "  ✅ Deleted $deletedCount files ($sizeMB MB)" -ForegroundColor Green
    Write-Host ""
}

# Clean both directories
Write-Host "🧹 Cleaning Project Directory..." -ForegroundColor Cyan
Clean-Directory -path $projectPath

Write-Host "🧹 Cleaning OneDrive Backup..." -ForegroundColor Cyan
Clean-Directory -path $oneDrivePath

Write-Host "✅ Cleanup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "  - Temporary files removed" -ForegroundColor White
Write-Host "  - Duplicate documentation removed" -ForegroundColor White
Write-Host "  - Old status files removed" -ForegroundColor White
Write-Host "  - Essential files preserved" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: Review the remaining files and delete any other unnecessary files manually." -ForegroundColor Yellow

