function Write-ColorText {
    <#
        .SYNOPSIS
            Write to the console in 24-bit colors!
        .DESCRIPTION
            This function lets you write to the console using 24-bit color depth.
            You can specify colors using its RGB values.
        .EXAMPLE
            Write-RGB -Text "Hello World!" -FG Goldenrod -BG BlueViolet -UnderLine

            Will write the text using the default colors.
        .NOTES
            Modified version of Øyvind Kallstad Write-RGB function (https://communary.net). I wanted something that could color PSCustomObject String property
            and that could be used for color format.ps1xml files. Also wanted to add tab completetion with KnownColor Type.
    #>
    [CmdletBinding()]
    param (
        # The text you want to write.
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Text,
        [Parameter(Position = 1)]
        [ALias("FG")]
        [System.Drawing.KnownColor]$ForegroundColor = [System.Drawing.KnownColor]::[System.Console]::ForegroundColor,
        [Parameter(Position = 2)]
        [Alias("BG")]
        [System.Drawing.KnownColor]$BackgroundColor = [System.Drawing.KnownColor]::[System.Console]::BackgroundColor,
        [Parameter(Position = 3)]
        [Alias("UL")]
        [switch] $UnderLine
    )

    $escape = [char]27 + '['
    $resetAttributes = "$($escape)0m"
    $FGColor = [System.Drawing.Color]::FromKnownColor($ForegroundColor)
    $BGColor = [System.Drawing.Color]::FromKnownColor($BackgroundColor)
    
    $foreground = "$($escape)38;2;$($FGColor.R);$($FGColor.G);$($FGColor.B)m"
    $background = "$($escape)48;2;$($BGColor.R);$($BGColor.G);$($BGColor.B)m"
    if ($UnderLine){
        $UL = "$($escape)4m"
    }
    else{$UL = $null}
    
    $WriteHost = $escape + $foreground + $background + $UL + $Text + $resetAttributes
    $WriteHost
}