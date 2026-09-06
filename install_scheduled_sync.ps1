<#
.SYNOPSIS
    Installs a per-user task that publishes the dashboard snapshot every 15 minutes.
#>
[CmdletBinding()]
param(
    [ValidateRange(5, 1440)]
    [int]$IntervalMinutes = 15,
    [switch]$RunNow
)

$ErrorActionPreference = "Stop"
$TaskName = "ProjectsDashboardSync"
$DashboardRoot = $PSScriptRoot
$SyncScript = Join-Path $DashboardRoot "sync_dashboard.ps1"
$PowerShellExe = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"

if (-not (Test-Path -LiteralPath $SyncScript -PathType Leaf)) {
    throw "Sync script does not exist: $SyncScript"
}

$action = New-ScheduledTaskAction -Execute $PowerShellExe -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$SyncScript`""
$trigger = New-ScheduledTaskTrigger -Daily -At "00:00" -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) -RepetitionDuration (New-TimeSpan -Days 1)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 10) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Scans E:\App AI and publishes the safe projects dashboard snapshot." -Force | Out-Null
Write-Host "[+] Installed scheduled task '$TaskName' every $IntervalMinutes minutes." -ForegroundColor Green

if ($RunNow) {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "[+] Started '$TaskName' now." -ForegroundColor Green
}
