function Start-Tic_Tac_Toe{
    param(
        [ValidateSet("Easy","Hard")]
        $DifficultyLevel
    )
    <#
    To Do:

    1. [X] Draw-Board
    2. [X]Create Easy Bot
    3. [X]Create Hard Bot

    #>

    #$Chars = '┌─┐│└┘'
    $Player = 'X'
    $top = [console]::CursorTop
    $PlayerOScore = 0
    $PLayerXScore = 0

    #this creates the virtual gameboard 0 being the top most left, and 8 being the right most bottom
    $gameGrid =     0.. 8 | foreach {
        $YAdjust = if ($_ -lt 3){2}
        elseif($_ -gt 5){6}
        else{4}
        [PSCustomObject]@{
            Value = " "
            X = ($_ % 3) + 7 + (($_ % 3) * 3)
            Y = ($top + $YAdjust)
            ID = $_
        }
    }

    $cursor = 0

    function Mark-Move ($Player,$move){
        $gameGrid[$move].Value = $Player
    }

    Draw-Board -XS $PLayerXScore -OS $PlayerOScore
    [console]::SetCursorPosition($gameGrid[0].x,$gameGrid[0].y)


    do {
        $Key = [Console]::ReadKey($true)
        if ($Key.key -eq [ConsoleKey]::DownArrow){
            $previousPosition = $cursor
            $cursor = $cursor + 3
            if ($cursor -ge 9){
                $cursor = $cursor % 9
            }
            if ($gameGrid[$cursor].Value -eq " "){
                [console]::SetCursorPosition($gameGrid[$cursor].X,$gameGrid[$cursor].Y)
            }
            else{
                $cursor = $previousPosition
            }
        }
        elseif ($Key.key -eq [ConsoleKey]::UpArrow){
                $previousPosition = $cursor
                $cursor = $cursor - 3
                if ($cursor -le -1){
                    $cursor = 9 + $cursor
                }
                if ($gameGrid[$cursor].Value -eq " "){
                    [console]::SetCursorPosition($gameGrid[$cursor].X,$gameGrid[$cursor].Y)
                }
                else{
                    $cursor = $previousPosition
                }
        }
        elseif ($Key.key -eq [ConsoleKey]::RightArrow){
            $cursor = $cursor + 1
            if ($cursor -ge 9){
                $cursor = 0
            }
            while ($gameGrid[$cursor].Value -ne " "){
                $cursor++
            }
            [console]::SetCursorPosition($gameGrid[$cursor].X,$gameGrid[$cursor].Y)
        }
        elseif ($Key.key -eq [ConsoleKey]::LeftArrow){
            $cursor = $cursor - 1
            if ($cursor -lt 0){
                $cursor = 8
            }
            while ($gameGrid[$cursor].Value -ne " "){
                $cursor--
            }
            [console]::SetCursorPosition($gameGrid[$cursor].X,$gameGrid[$cursor].Y)
        }
        elseif ($key.Key -eq [ConsoleKey]::Enter){
            Mark-Move -Player $Player -move $cursor
            [console]::SetCursorPosition(0,$top)
            Draw-Board -XS $PLayerXScore -OS $PlayerOScore

            if (CheckWinConditions $gameGrid){
                $PLayerXScore++
                $gameGrid = New-GameBoard
                [console]::SetCursorPosition(0,$top)
                Write-GameResults -Results "X"
                sleep 2
                [console]::SetCursorPosition(0,$top)
                $WhiteSpace = (0.. ([console]::WindowWidth - 2) | foreach {"$([char]32)"})
                Write-Host "`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace`n$WhiteSpace"
                [console]::SetCursorPosition(0,$top)
                Draw-Board -XS $PLayerXScore -OS $PlayerOScore -Results  "X"
            }

            $Player = 'O'
            [console]::CursorVisible = $false
            sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 1000)
            $botMove = New-BotMove -Difficulty $DifficultyLevel -Grid $gameGrid
            [console]::SetCursorPosition(0,$top)
            [console]::CursorVisible = $true
            Draw-Board -XS $PLayerXScore -OS $PlayerOScore
            if (CheckWinConditions $gameGrid){
                $PLayerOScore++
                $gameGrid = New-GameBoard
                [console]::SetCursorPosition(0,$top)
                Write-GameResults -Results "O"
                sleep 1
                Draw-Board -XS $PLayerXScore -OS $PlayerOScore -Results "O"
            }

            $Player = 'X'
            for ($i = 0; $i -le 8; $i++){
                if ($gameGrid[$i].Value -eq " "){
                    $cursor = $i
                    [console]::SetCursorPosition($gameGrid[$cursor].x,$gameGrid[$cursor].y)
                    break;
                }
            }
        }
    }
    While( -not ([ConsoleKey]::Escape -eq $key.Key) )
}
