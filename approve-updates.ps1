# Approves the updates passed on standard input for the specified WSUS
# computer group.
#
# .\list-unapproved.ps1 > updates-YYYY-MM-DD.txt
#  ... file contains lines like "<update guid>:<revision number>;other info"
# cat updates-YYYY-MM-DD.txt | .\approve-updates.ps1 Test_Workstations

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
    Log "Approving for $($computer_group): $($_ | Wsus-Update-Info)"
    if ($_.RequiresLicenseAgreementAcceptance) {
        $_.AcceptLicenseAgreement()
    }
    [void] $_.Approve(
        [Microsoft.UpdateServices.Administration.UpdateApprovalAction]::Install,
        $installGroup)
}
