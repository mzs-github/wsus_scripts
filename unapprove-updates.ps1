# Removes update approvals for the updates passed on standard input for the
# specified WSUS computer group. This will override approvals for parent
# groups for the same updates.
#
# .\list-approved.ps1 Some_Group > approved-updates-YYYY-MM-DD.txt
#  ... file contains lines like "<update guid>:<revision number>;other info"
# cat approved-updates-YYYY-MM-DD.txt | .\unapprove-updates.ps1 Some_Group

param([string]$computer_group)

function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

# Die on error
$ErrorActionPreference = "Stop"

$scriptdir = Get-ScriptDirectory
. "$scriptdir\wsus.ps1"
. "$scriptdir\logging.ps1"

$wsus = Wsus-Object

$installGroup = Wsus-Group $wsus $computer_group

$input | Wsus-Update-Id-From-Info-Line | Wsus-Update-From-Id $wsus |
Foreach-Object {
    Log "Unapproving for $($computer_group): $($_ | Wsus-Update-Info)"
    [void] $_.Approve(
        [Microsoft.UpdateServices.Administration.UpdateApprovalAction]::NotApproved,
        $installGroup)
}
