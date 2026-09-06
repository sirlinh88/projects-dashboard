<#
.SYNOPSIS
    Compatibility entry point for a one-off dashboard scan and publication.
#>
[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Split-Path -Parent $PSScriptRoot)
)

& (Join-Path $PSScriptRoot "sync_dashboard.ps1") -WorkspaceRoot $WorkspaceRoot
exit $LASTEXITCODE
