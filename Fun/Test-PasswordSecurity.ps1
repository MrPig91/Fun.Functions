function Test-PasswordSecurity{
    param(
        [Parameter(Mandatory)]
        [securestring]$Password
    )
    $StringBuilder = New-Object System.Text.StringBuilder
    $Cred = [pscredential]::new("User",$Password)
    [System.Security.Cryptography.HashAlgorithm]::Create("SHA1").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Cred.GetNetworkCredential().Password)) |
        foreach {[Void]$StringBuilder.Append($_.ToString("x2"))}
    $Hash = $StringBuilder.ToString()
    $First5 = $Hash.Substring(0,5)
    $Results = (Invoke-RestMethod -Uri "https://api.pwnedpasswords.com/range/$First5").split("`n") | foreach {
        [PSCustomObject]@{
            Hash = $First5 + $_.Split(':')[0]
            PasswordsFound = [int]($_.Split(':')[1])
        }
    }
    if ($Results.Hash -contains $Hash){
        $Count = ($Results | where Hash -eq $Hash).PasswordsFound
        Write-Warning "Password is inscure! Do not use this password! $Count Passwords found on pwnedpasswords!"
    }
    else{
        Write-Host "Password has never been seen before. Safe to use." -ForegroundColor Green
    }
}