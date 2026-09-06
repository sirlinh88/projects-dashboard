<#
.SYNOPSIS
    Refreshes the local-only dashboard snapshot.

.DESCRIPTION
    Public dashboard status is published exclusively by GitHub Actions. This script
    intentionally never stages, commits, or pushes local repository data.
#>
[CmdletBinding()]
param(
    [string]$WorkspaceRoot
)

$ErrorActionPreference = 'Stop'
$DashboardRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = Split-Path -Parent $DashboardRoot
}

$scannerScript = Join-Path $DashboardRoot 'scan_repos_status.ps1'
$localDataFile = Join-Path $DashboardRoot 'local_projects_data.js'
& powershell -NoProfile -ExecutionPolicy Bypass -File $scannerScript -WorkspaceRoot $WorkspaceRoot -OutputPath $localDataFile -RefreshRemote
if ($LASTEXITCODE -ne 0) {
    throw "Repository scan failed with exit code $LASTEXITCODE."
}

Write-Host '[+] Local dashboard snapshot refreshed. Public status is event-driven via GitHub Actions.' -ForegroundColor Green
