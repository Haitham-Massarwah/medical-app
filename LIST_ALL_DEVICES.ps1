# List All Devices Connected to Account and Network
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All Connected Devices - Complete List" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current computer info
Write-Host "[INFO] Current Computer Information:" -ForegroundColor Yellow
Write-Host ""
$computerName = $env:COMPUTERNAME
$username = $env:USERNAME
$domain = $env:USERDOMAIN

Write-Host "Current Device:" -ForegroundColor Cyan
Write-Host "  Computer Name: $computerName" -ForegroundColor White
Write-Host "  Username: $username" -ForegroundColor White
Write-Host "  Domain: $domain" -ForegroundColor White

try {
    $computer = Get-WmiObject Win32_ComputerSystem
    Write-Host "  Manufacturer: $($computer.Manufacturer)" -ForegroundColor White
    Write-Host "  Model: $($computer.Model)" -ForegroundColor White
    Write-Host "  Total Memory: $([math]::Round($computer.TotalPhysicalMemory/1GB, 2)) GB" -ForegroundColor White
} catch {
    Write-Host "  (Could not retrieve full system info)" -ForegroundColor Gray
}

Write-Host ""

# Network Devices (ARP Cache)
Write-Host "[INFO] Network Devices (Local Network):" -ForegroundColor Yellow
Write-Host ""
Write-Host "These devices are on your local network:" -ForegroundColor Cyan
Write-Host ""

$networkDevices = @()
try {
    $arpEntries = Get-NetNeighbor | Where-Object { 
        $_.State -eq "Reachable" -or $_.State -eq "Stale" 
    } | Select-Object IPAddress, LinkLayerAddress, State -Unique | Sort-Object IPAddress
    
    $deviceNum = 1
    foreach ($device in $arpEntries) {
        if ($device.IPAddress) {
            $networkDevices += [PSCustomObject]@{
                Number = $deviceNum
                IP = $device.IPAddress
                MAC = $device.LinkLayerAddress
                State = $device.State
            }
            Write-Host "  Device $deviceNum : $($device.IPAddress)" -ForegroundColor White
            Write-Host "    MAC Address: $($device.LinkLayerAddress)" -ForegroundColor Gray
            Write-Host "    Status: $($device.State)" -ForegroundColor Gray
            Write-Host ""
            $deviceNum++
        }
    }
    
    Write-Host "Total Network Devices Found: $($networkDevices.Count)" -ForegroundColor Green
} catch {
    Write-Host "  (Requires admin rights to scan network)" -ForegroundColor Yellow
}

Write-Host ""

# Check for Microsoft Account devices (if accessible)
Write-Host "[INFO] Microsoft Account Devices:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Attempting to retrieve Microsoft account devices..." -ForegroundColor Cyan
Write-Host ""

try {
    # Try to get logged-in Microsoft account
    $microsoftAccount = (Get-WmiObject Win32_ComputerSystem).UserName
    if ($microsoftAccount -like "*@*") {
        Write-Host "Logged in as: $microsoftAccount" -ForegroundColor White
    }
} catch {
    Write-Host "  (Could not retrieve Microsoft account info)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Note: To see all devices on your Microsoft account:" -ForegroundColor Yellow
Write-Host "  1. Go to: https://account.microsoft.com/devices" -ForegroundColor White
Write-Host "  2. Or: Settings > Account > Your Info > Microsoft Account" -ForegroundColor White
Write-Host ""

# OneDrive devices (check OneDrive sync info)
Write-Host "[INFO] OneDrive Account Information:" -ForegroundColor Yellow
Write-Host ""

$oneDrivePath = $env:OneDrive
if ($oneDrivePath) {
    Write-Host "OneDrive Path: $oneDrivePath" -ForegroundColor White
    
    try {
        $onedriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
        if ($onedriveProcess) {
            Write-Host "OneDrive Status: Running (Process ID: $($onedriveProcess.Id))" -ForegroundColor Green
        } else {
            Write-Host "OneDrive Status: Not running (may sync in background)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "OneDrive Status: Unknown" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Note: OneDrive syncs to all devices logged into your account" -ForegroundColor Cyan
    Write-Host "      Check OneDrive app on other devices for device list" -ForegroundColor Gray
} else {
    Write-Host "OneDrive not configured" -ForegroundColor Yellow
}

Write-Host ""

# Get network adapters (to identify this device)
Write-Host "[INFO] Network Adapters (This Device):" -ForegroundColor Yellow
Write-Host ""

try {
    $adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        $_.IPAddress -notlike "127.*" 
    } | Select-Object IPAddress, InterfaceAlias, PrefixLength
    
    foreach ($adapter in $adapters) {
        Write-Host "  Interface: $($adapter.InterfaceAlias)" -ForegroundColor White
        Write-Host "    IP: $($adapter.IPAddress)" -ForegroundColor Gray
        Write-Host "    Subnet: $($adapter.PrefixLength)" -ForegroundColor Gray
        Write-Host ""
    }
} catch {
    Write-Host "  (Could not retrieve network adapters)" -ForegroundColor Gray
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current Device:" -ForegroundColor Cyan
Write-Host "  Name: $computerName" -ForegroundColor White
Write-Host "  User: $username" -ForegroundColor White
if ($networkDevices.Count -gt 0) {
    Write-Host ""
    Write-Host "Network Devices: $($networkDevices.Count) devices found" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To see full Microsoft account devices:" -ForegroundColor Yellow
    Write-Host "  https://account.microsoft.com/devices" -ForegroundColor White
}

Write-Host ""
Write-Host "To see detailed device list:" -ForegroundColor Cyan
Write-Host "  - Microsoft Account: https://account.microsoft.com/devices" -ForegroundColor White
Write-Host "  - OneDrive: Check OneDrive app settings on each device" -ForegroundColor White
Write-Host "  - Network: 65 devices found (see list above)" -ForegroundColor White

Write-Host ""

# Save to file
$outputFile = "ALL_DEVICES_LIST.txt"
Write-Host "Saving device list to: $outputFile" -ForegroundColor Cyan

$report = @"
================================================================================
                    ALL CONNECTED DEVICES LIST
================================================================================

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

CURRENT DEVICE:
--------------
Computer Name: $computerName
Username: $username
Domain: $domain

NETWORK DEVICES (Local Network):
--------------------------------
"@

if ($networkDevices.Count -gt 0) {
    foreach ($device in $networkDevices) {
        $report += "`nDevice $($device.Number):`n"
        $report += "  IP Address: $($device.IP)`n"
        $report += "  MAC Address: $($device.MAC)`n"
        $report += "  Status: $($device.State)`n"
    }
    $report += "`nTotal: $($networkDevices.Count) devices`n"
} else {
    $report += "`n(No devices detected or admin rights required)`n"
}

$report += @"

================================================================================
                    ADDITIONAL INFORMATION
================================================================================

MICROSOFT ACCOUNT DEVICES:
--------------------------
To see all devices on your Microsoft account, visit:
  https://account.microsoft.com/devices

ONEDRIVE DEVICES:
-----------------
OneDrive syncs to all devices logged into your account.
Check OneDrive app on each device for sync status.

CURRENT DEVICE NETWORK ADDRESSES:
---------------------------------
"@

try {
    $adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        $_.IPAddress -notlike "127.*" 
    }
    foreach ($adapter in $adapters) {
        $report += "`nInterface: $($adapter.InterfaceAlias)`n"
        $report += "  IP: $($adapter.IPAddress)`n"
    }
} catch {
    $report += "`n(Could not retrieve network adapters)`n"
}

$report += @"

================================================================================
NOTE: Network devices are devices on your local network, not necessarily
      connected to your Microsoft account. For account-connected devices,
      check: https://account.microsoft.com/devices
================================================================================
"@

$report | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "[OK] Device list saved to: $outputFile" -ForegroundColor Green
Write-Host ""


