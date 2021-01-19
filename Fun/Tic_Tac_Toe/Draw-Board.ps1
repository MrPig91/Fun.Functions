function Draw-Board {
    param(
        $XS,
        $OS,
        $WhiteSpace
    )
    $line = (0.. 12 | foreach {[char]9472}) -join ''
    $topborder = ([char]9484,$line,[char]9488) -join ''

    $middleLine = (0.. 2 | foreach {[char]9472}) -join ''
    $middleborder = $middleLine,[char]9532,$middleLine,[char]9532,$middleLine -join ''

    $bottomborder = ([char]9492,$line,[char]9496) -join ''
    $WhiteSpace = (0.. [console]::WindowWidth | foreach {[char]32}) -join ''

    $Board = "
    $topborder   $topborder
    $([char]9474)  $(Write-Letter $gameGrid[0].Value) $([char]9474) $(Write-Letter $gameGrid[1].Value) $([char]9474) $(Write-Letter $gameGrid[2].Value)  $([char]9474)   $([char]9474)    SCORE    $([char]9474)
    $([char]9474) $middleborder $([char]9474)   $([char]9500)$line$([char]9508) 
    $([char]9474)  $(Write-Letter $gameGrid[3].Value) $([char]9474) $(Write-Letter $gameGrid[4].Value) $([char]9474) $(Write-Letter $gameGrid[5].Value)  $([char]9474)   $([char]9474) Player X: $($XS.ToString("0")) $([char]9474)  
    $([char]9474) $middleborder $([char]9474)   $([char]9474) Player O: $($OS.ToString("0")) $([char]9474)  
    $([char]9474)  $(Write-Letter $gameGrid[6].Value) $([char]9474) $(Write-Letter $gameGrid[7].Value) $([char]9474) $(Write-Letter $gameGrid[8].Value)  $([char]9474)   $bottomborder
    $bottomborder
        "
       Write-Host $Board
       <# if ($Results){
            Write-GameResults -Results $Results
        }
        else{
            Write-Host "`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace"
        } #>
}