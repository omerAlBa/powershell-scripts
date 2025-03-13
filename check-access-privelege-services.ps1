# Get the current user's identity
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Get the list of groups the current user belongs to
$userGroups = [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | ForEach-Object {
    $_.Translate([System.Security.Principal.NTAccount]).Value
}

# Add the current user and "INTERACTIVE" to the list of identities to check
$identitiesToCheck = @($currentUser, "NT AUTHORITY\INTERACTIVE") + $userGroups

# Search for services with vulnerable permissions
Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" | ForEach-Object {
    $serviceName = $_.PSChildName
    $acl = Get-Acl -Path $_.PSPath
    $acl.Access | Where-Object {
        ($identitiesToCheck -contains $_.IdentityReference) -and
        ($_.RegistryRights -match "Write|FullControl")
    } | ForEach-Object {
        Write-Host "[!] Vulnerable Service: $serviceName"
        Write-Host "    Path:  HKLM:\SYSTEM\CurrentControlSet\Services"
        Write-Host "    Permissions: $($_.RegistryRights)"
        Write-Host "    Who: $($_.IdentityReference)"
    }
}
