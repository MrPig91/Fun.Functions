
function Add-ForgottenVariableKeyHandle {
    param(
        [string]$Key = "Ctrl+V",
        [string]$BriefDescription = "AddVariable",
        [string]$Description = "Add new variable to start the start of the line"
    )


    Set-PSReadLineKeyHandler -Key $Key -BriefDescription $BriefDescription -Description $Description -ScriptBlock{
        param($key, $arg)

        #This will bu used to make our variable name plural
        Add-Type -AssemblyName System.Data.Entity.Design
        $PluralService = [System.Data.Entity.Design.PluralizationServices.PluralizationService]::CreateService($PSCulture)
        
        #grabbing ast object from the currently written line
        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
        
        #grabbing if anyting is currently selected
        $selectionStart = $null
        $selectionLength = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
        
        #grabbing what is written currently and where the cursor position is
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        #Check to see if the line starts with a variable, if so toggle between singular and plural nouns and exit the function
        if ($line.StartsWith('$') -and ($line.Contains('='))){
            $variableName = $line.Split('=',2)[0].Replace('$','').TrimEnd()
            $newLine = $line.Split('=',2)[1].TrimStart()
            if ($PluralService.IsSingular($variableName)){
                $variableName = $PluralService.Pluralize($variableName)
            }
            else{
                $variableName = $PluralService.Singularize($variableName)
            }
            $variableName = '$' + $variableName + " "
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $variableName + "= " + $newline)
            [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
            return
        }

        $commandAst = $ast.FindAll( {
            $node = $args[0]
            $node -is [System.Management.Automation.Language.CommandAst]
            }, $true)
            
        #function to get the nouns of the first and last commands in the pipeline
        function Get-CommandNounandVerb ([System.Management.Automation.Language.CommandAst[]]$commandAst){
            foreach ($cmdAst in $commandAst) {
                $commandName = $cmdAst.GetCommandName()
                if ($commandName){
                    $command = $ExecutionContext.InvokeCommand.GetCommand($CommandName, 'All')
                    if ($command -is [System.Management.Automation.AliasInfo]){
                        $commandName = $command.ResolvedCommandName
                        if ($commandName.Contains('-')){
                            [PSCustomObject]@{
                                Verb = $commandName.Split('-')[0]
                                Noun = $commandName.Split('-')[1]
                            }
                        }
                        else{
                            [PSCustomObject]@{
                                Verb = $null
                                Noun = $commandName
                            }
                        }
                    } #if alias get full command name
                    else{
                        if ($commandName.Contains('-')){
                            [PSCustomObject]@{
                                Verb = $commandName.Split('-')[0]
                                Noun = $commandName.Split('-')[1]
                            }
                        }
                        else{
                            [PSCustomObject]@{
                                Verb = $null
                                Noun = $commandName
                            }
                        }
                    }
                } #if commandName
            } #foreach
        } #function
    
    
        if ($commandAst){
            $nounNames = Get-CommandNounandVerb -commandAst $commandAst
            if (($nounNames | measure).Count -eq 1){
                $VariableName = $nounNames.Noun
            }
            elseif ($nounNames.Count -gt 1){
                if ($nounNames.Verb -contains "Select"){
                    $VariableName = $nounNames[0].Noun.ToLower() + "PSObject"
                } #if the last cmdlet noun is Object
                elseif (($nounNames | select -Last 1).verb -eq "Where"){
                    $VariableName = ($nounNames | select -Last 2)[0].Noun
                }
                else{
                    $VariableName = ($nounNames | select -Last 1).Noun
                }
            } #else if 2 commands in the pipeline

            $VariableName  = $PluralService.Pluralize($VariableName)

            $CurrentVariables = Get-Variable
            $i = 1
            while ($CurrentVariables.Name -contains "$($VariableName)"){
                $i++
                $VariableName = $VariableName.TrimEnd("$($i - 1)") + $i 
            } #while this variable name already gets exist add numbers
            $VariableName = '$' + $VariableName + ' = '
    
            if (!$line.StartsWith('$') -and ($selectionStart -eq -1)){
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $VariableName + $line)
                [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
            } #if line doesn't already start with a variable and nothing is selected
        } #if commandast exists
    } #scriptblock to run when Ctrl+V is pressed
}