# Automated Task Tracker Update Script
# Updates AUTOMATED_TASKS.md with current progress

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "complete", "block", "cancel")]
    [string]$Action,
    
    [Parameter(Mandatory=$true)]
    [int]$TaskNumber,
    
    [string]$Notes = ""
)

$tasksFile = "C:\Projects\medical-app\AUTOMATED_TASKS.md"

if (-not (Test-Path $tasksFile)) {
    Write-Host "❌ Tasks file not found!" -ForegroundColor Red
    exit 1
}

$content = Get-Content $tasksFile -Raw

# Status mapping
$statusMap = @{
    "start" = "🔄 **In Progress**"
    "complete" = "✅ **Completed**"
    "block" = "⚠️ **Blocked**"
    "cancel" = "❌ **Cancelled**"
}

$newStatus = $statusMap[$Action]

# Update task status
$pattern = "(### $TaskNumber\.\s+\*\*.*?\*\*\s+-)\s+\*\*Status:\*\*\s+.*?"
$replacement = "`$1 **Status:** $newStatus"

$content = $content -replace $pattern, $replacement

# Add notes if provided
if ($Notes -ne "") {
    $notePattern = "(### $TaskNumber\.\s+\*\*.*?\*\*\s+-.*?)(\n\n---)"
    $noteText = "`n- **Notes:** $Notes`n"
    $content = $content -replace $notePattern, "`$1$noteText`$2"
}

# Update progress
$completedTasks = ([regex]::Matches($content, "✅ \*\*Completed\*\*")).Count
$inProgressTasks = ([regex]::Matches($content, "🔄 \*\*In Progress\*\*")).Count
$totalTasks = 9

$progressPercent = [math]::Round(($completedTasks / $totalTasks) * 100)

$progressPattern = "### Overall Progress: \*\*.*?%\*\*"
$progressReplacement = "### Overall Progress: **$progressPercent% Complete**"

$content = $content -replace $progressPattern, $progressReplacement

# Update counts
$countPattern = "\*\*Completed:\*\* \d+/\d+ tasks.*?"
$countReplacement = "**Completed:** $completedTasks/$totalTasks tasks ($([math]::Round(($completedTasks/$totalTasks)*100))%)"

$content = $content -replace $countPattern, $countReplacement

$inProgressPattern = "\*\*In Progress:\*\* \d+/\d+ tasks.*?"
$inProgressReplacement = "**In Progress:** $inProgressTasks/$totalTasks tasks ($([math]::Round(($inProgressTasks/$totalTasks)*100))%)"

$content = $content -replace $inProgressPattern, $inProgressReplacement

$pendingPattern = "\*\*Pending:\*\* \d+/\d+ tasks.*?"
$pendingCount = $totalTasks - $completedTasks - $inProgressTasks
$pendingReplacement = "**Pending:** $pendingCount/$totalTasks tasks ($([math]::Round(($pendingCount/$totalTasks)*100))%)"

$content = $content -replace $pendingPattern, $pendingReplacement

# Save updated content
Set-Content -Path $tasksFile -Value $content -NoNewline

Write-Host "✅ Task $TaskNumber updated: $Action" -ForegroundColor Green
if ($Notes -ne "") {
    Write-Host "📝 Notes: $Notes" -ForegroundColor Cyan
}
Write-Host "📊 Progress: $progressPercent% Complete" -ForegroundColor Cyan

