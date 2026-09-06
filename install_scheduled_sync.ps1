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

$TaskCommand = "\`"$PowerShellExe\`" -NoProfile -ExecutionPolicy Bypass -File \`"$SyncScript\`""
& schtasks.exe /Create /TN $TaskName /TR $TaskCommand /SC MINUTE /MO $IntervalMinutes /F
if ($LASTEXITCODE -ne 0) {
    throw "Could not create scheduled task '$TaskName'."
}

$task = Get-ScheduledTask -TaskName $TaskName
$task.Settings.DisallowStartIfOnBatteries = $false
$task.Settings.StopIfGoingOnBatteries = $false
Set-ScheduledTask -InputObject $task | Out-Null

Write-Host "[+] Installed scheduled task '$TaskName' every $IntervalMinutes minutes." -ForegroundColor Green

if ($RunNow) {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "[+] Started '$TaskName' now." -ForegroundColor Green
}
