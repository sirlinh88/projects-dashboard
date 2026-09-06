<#
.SYNOPSIS
    Scans the local workspace and publishes only the generated public snapshot.

.DESCRIPTION
    Safe to schedule: this script never stages unrelated dashboard changes.
#>
[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$NoPush
)

$ErrorActionPreference = "Stop"
$DashboardRoot = $PSScriptRoot
$ScannerScript = Join-Path $DashboardRoot "scan_repos_status.ps1"
$DataFile = Join-Path $DashboardRoot "projects_data.js"
$Mutex = New-Object System.Threading.Mutex($false, "ProjectsDashboardSync")
$hasLock = $false

try {
    $hasLock = $Mutex.WaitOne(0)
    if (-not $hasLock) {
        Write-Host "[i] A dashboard sync is already running; this invocation was skipped." -ForegroundColor Yellow
        exit 0
    }

    if (-not (Test-Path -LiteralPath $ScannerScript -PathType Leaf)) {
        throw "Scanner script does not exist: $ScannerScript"
    }

    $branch = (& git -C $DashboardRoot branch --show-current).Trim()
    if ($LASTEXITCODE -ne 0 -or $branch -ne "main") {
        throw "Dashboard repository must be on branch 'main'; current branch is '$branch'."
    }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $ScannerScript -WorkspaceRoot $WorkspaceRoot -OutputPath $DataFile -RefreshRemote
    if ($LASTEXITCODE -ne 0) {
        throw "Repository scan failed with exit code $LASTEXITCODE."
    }

    & git -C $DashboardRoot add -- projects_data.js
    if ($LASTEXITCODE -ne 0) {
        throw "Could not stage projects_data.js."
    }

    & git -C $DashboardRoot diff --cached --quiet -- projects_data.js
    $hasSnapshotChange = $LASTEXITCODE -ne 0
    if (-not $hasSnapshotChange) {
        Write-Host "[i] No dashboard snapshot change to publish." -ForegroundColor Cyan
        exit 0
    }

    $commitMessage = "sync: update repository status $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    & git -C $DashboardRoot commit -m $commitMessage -- projects_data.js
    if ($LASTEXITCODE -ne 0) {
        throw "Could not commit the dashboard snapshot."
    }

    if (-not $NoPush) {
        & git -C $DashboardRoot push origin main
        if ($LASTEXITCODE -ne 0) {
            throw "Could not push the dashboard snapshot to origin/main."
        }
        Write-Host "[+] Dashboard snapshot published to GitHub Pages." -ForegroundColor Green
    }
}
finally {
    if ($hasLock) {
        $Mutex.ReleaseMutex()
    }
    $Mutex.Dispose()
}
