
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")

Function Wsus-Object()
{
    return `
        [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer(
            $env:COMPUTERNAME, $False)
}

# Formats an IUpdate as <guid>:<revision number>
Filter Wsus-Update-Id()
{
    return "$($_.Id.UpdateId):$($_.Id.RevisionNumber)"
}

# Given an update formatted as <guid>:<revision number>, returns the IUpdate
Filter Wsus-Update-From-Id($wsus)
{
    $a = $_.split(':')
    $guid = $a[0]
    $rev = $a[1]
    $uid = New-Object Microsoft.UpdateServices.Administration.UpdateRevisionId(
        $guid, $rev)
    return $wsus.GetUpdate($uid)
}

# Given an IUpdate, returns a string suitable for logging or display.
Filter Wsus-Update-Info()
{
    # Sanitize the title strings.
    # KB2416754's title had a newline that threw things off.
    $title = [System.Text.RegularExpressions.Regex]::Replace(
        $_.Title, "[^0-9a-zA-Z_ !@#%&*()+=/:,.<>{}\[\]-]", "")
    return "$($_ | Wsus-Update-Id);$($_.CreationDate.ToShortDateString());$title"
}

# Given a semicolon-separated line from Wsus-Update-Info, returns just the
# <guid>:<revision number> (first column)
Filter Wsus-Update-Id-From-Info-Line()
{
    return $_.split(';')[0]
}

# Looks up the WSUS computer group named $group
Function Wsus-Group($wsus, $group)
{
    $installGroup = $wsus.GetComputerTargetGroups() |
        where {$_.Name -eq $group}
    if ($installGroup -eq $null) {
        Write-Error "Could not find group $group"
        Return
    }
    if ($installGroup.count) {
        Write-Error "Expected only one group called $group, but found $($installGroup.count)"
        Return
    }
    return $installGroup
}
