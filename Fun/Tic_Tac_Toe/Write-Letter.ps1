function Write-Letter{
    param(
        [ValidateSet("X","O"," ")]
        $Letter
    )
    $Esc = [char]27
    if ($Letter -eq "X"){
        "$($Esc)[92m$Letter$($Esc)[39m"
    }
    elseif ($Letter -eq "O"){
        "$($Esc)[91m$Letter$($Esc)[39m"
    }
    else{
        " "
    }
}