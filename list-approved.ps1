# List the updates approved for the given group. Does not include
# updates approved for parent groups.
#
# Run in PowerShell as admin.
# .\list-approved.ps1 Test_Workstations

param([string]$computer_group)

function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

# Die on error
$ErrorActionPreference = "Stop"

$scriptdir = Get-ScriptDirectory
. "$scriptdir\wsus.ps1"

$wsus = Wsus-Object

$installGroup = Wsus-Group $wsus $computer_group

$updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$updateScope.ApprovedStates =
    [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved

[void] $updateScope.ApprovedComputerTargetGroups.add($installGroup)

$approved = $wsus.GetUpdates($updateScope)
if ($approved -ne $null) {
    $approved | Wsus-Update-Info | Write-Output
}
