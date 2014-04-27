# Log to wsus_scripts.log in the same directory as the script.
$script_dir = Split-Path $script:MyInvocation.MyCommand.Path
$LOGFILE = "$script_dir\wsus_scripts.log"

Function Log([string] $log)
{
    Add-Content $LOGFILE -value "$(Get-Date -format g) $log"
}

function Fatal([string] $log)
{
    Log($log)
    Write-Host "FATAL: $log"
    Exit 1
}
