
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
    
        $commandAst = $ast.FindAll( {
            $node = $args[0]
            $node -is [System.Management.Automation.Language.CommandAst]
            }, $true) | Select-Object -First 1 -Last 1
            
        #function to get the nouns of the first and last commands in the pipeline
        function Get-CommandNoun ([System.Management.Automation.Language.CommandAst[]]$commandAst){
            foreach ($cmdAst in $commandAst) {
                    $commandName = $cmdAst.GetCommandName()
                if ($commandName){
                    $command = $ExecutionContext.InvokeCommand.GetCommand($CommandName, 'All')
                    if ($command -is [System.Management.Automation.AliasInfo]){
                        $commandName = $command.ResolvedCommandName
                        $commandName.Split('-')[1]
                    }
                    else{
                        $commandName.Split('-')[1]
                    }
                } #if commandName
            } #foreach
        } #function
    
    
        if ($commandAst){
            $nounNames = Get-CommandNoun -commandAst $commandAst
            if ($nounNames.count -eq 1){
                $VariableName = $nounNames
            }
            elseif ($nounNames.Count -eq 2){
                if ($nounNames[1] -eq "Object"){
                    $VariableName = $nounNames[0].ToLower() + 'PS' + $nounNames[1]
                } #if the last cmdlet noun is Object
                else{
                    $VariableName = $nounNames[1]
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