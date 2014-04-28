# Lists unapproved updates, one per line, as <guid>:<revisionnumber>;date;title.
# Run in PowerShell as admin.
#
function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

# Die on error
$ErrorActionPreference = "Stop"

$scriptdir = Get-ScriptDirectory
. "$scriptdir\wsus.ps1"

$wsus = Wsus-Object

# Get the list of all updates that are not declined.
$unapprovedUpdates = $wsus.GetUpdates() | where {
    $_.IsDeclined -ne $True -and $_.IsApproved -ne $True
}
if ($unapprovedUpdates -ne $null) {
    $unapprovedUpdates | Wsus-Update-Info
}
