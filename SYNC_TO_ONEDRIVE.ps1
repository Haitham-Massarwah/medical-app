# End-of-Day Sync Script
# Syncs local project to OneDrive backup location

Write-Host "🔄 Starting End-of-Day Sync..." -ForegroundColor Cyan
Write-Host ""

$localPath = "C:\Projects\medical-app"
$oneDrivePath = "C:\Users\hitha\OneDrive\Desktop\Haitham-Works\App"

# Directories to sync
$syncDirs = @(
    "lib",
    "backend",
    "assets",
    "android",
    "ios",
    "web",
    "windows",
    "test",
    "integration_test",
    "DOCUMENTATION",
    "CLINIC_INSTALLATION"
)

# Files to sync
$syncFiles = @(
    "pubspec.yaml",
    "pubspec.lock",
    "ENVIRONMENT.txt",
    "ENVIRONMENT_SWITCH_GUIDE.md",
    "PROJECT_STATUS_REPORT.md",
    "QUICK_SUMMARY.md",
    "README.md",
    "docker-compose.yml",
    "*.json",
    "*.md",
    "*.txt"
)

# Exclude patterns
$excludePatterns = @(
    "node_modules",
    ".dart_tool",
    "build",
    ".git",
    "*.log",
    "*.tmp",
    "*.temp",
    "*.bak",
    "~$*"
)

function Sync-Directory {
    param($source, $dest, $dirName)
    
    if (-not (Test-Path $source)) {
        Write-Host "⚠️  Source not found: $dirName" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📁 Syncing: $dirName..." -ForegroundColor Cyan
    
    try {
        # Create destination if it doesn't exist
        if (-not (Test-Path $dest)) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        }
        
        # Use robocopy for efficient syncing
        $robocopyArgs = @(
            $source,
            $dest,
            "/E",           # Include subdirectories
            "/XD",          # Exclude directories
            "node_modules",
            ".dart_tool",
            "build",
            ".git",
            "/XF",          # Exclude files
            "*.log",
            "*.tmp",
            "*.temp",
            "*.bak",
            "~$*",
            "/NFL",         # No file list
            "/NDL",         # No directory list
            "/NJH",         # No job header
            "/NJS"          # No job summary
        )
        
        $result = robocopy @robocopyArgs 2>&1
        $exitCode = $LASTEXITCODE
        
        # Robocopy returns 0-7 for success, 8+ for errors
        if ($exitCode -le 7) {
            Write-Host "  ✅ Synced: $dirName" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Issues syncing: $dirName (Exit code: $exitCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ❌ Error syncing $dirName : $_" -ForegroundColor Red
    }
}

function Sync-Files {
    param($sourcePath, $destPath)
    
    Write-Host "📄 Syncing root files..." -ForegroundColor Cyan
    
    Get-ChildItem -Path $sourcePath -File | ForEach-Object {
        $file = $_
        $shouldSync = $false
        
        # Check if file matches sync patterns
        foreach ($pattern in $syncFiles) {
            if ($file.Name -like $pattern) {
                $shouldSync = $true
                break
            }
        }
        
        # Check if file should be excluded
        foreach ($exclude in $excludePatterns) {
            if ($file.Name -like $exclude) {
                $shouldSync = $false
                break
            }
        }
        
        if ($shouldSync) {
            try {
                $destFile = Join-Path $destPath $file.Name
                Copy-Item $file.FullName -Destination $destFile -Force
                Write-Host "  ✅ Synced: $($file.Name)" -ForegroundColor Green
            } catch {
                Write-Host "  ⚠️  Could not sync: $($file.Name)" -ForegroundColor Yellow
            }
        }
    }
}

# Create backup directory if it doesn't exist
if (-not (Test-Path $oneDrivePath)) {
    Write-Host "📁 Creating backup directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $oneDrivePath -Force | Out-Null
}

# Sync directories
Write-Host "🔄 Syncing directories..." -ForegroundColor Cyan
Write-Host ""
foreach ($dir in $syncDirs) {
    $sourceDir = Join-Path $localPath $dir
    $destDir = Join-Path $oneDrivePath $dir
    Sync-Directory -source $sourceDir -dest $destDir -dirName $dir
}

Write-Host ""
Write-Host "🔄 Syncing root files..." -ForegroundColor Cyan
Sync-Files -sourcePath $localPath -destPath $oneDrivePath

Write-Host ""
Write-Host "✅ Sync Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  - Local: $localPath" -ForegroundColor White
Write-Host "  - Backup: $oneDrivePath" -ForegroundColor White
Write-Host "  - Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: Run this script at the end of each day to keep OneDrive backup updated." -ForegroundColor Yellow

