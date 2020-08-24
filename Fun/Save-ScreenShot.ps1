function Save-ScreenCapture{
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="ChooseProcesses")]
        [ArgumentCompleter({
            param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
                Get-Process | where MainWindowTitle -ne "" | where MainWindowTitle -like "*$wordToComplete*" | foreach {
                    [System.Management.Automation.CompletionResult]::new("'$($_.ID)'",$_.MainWindowTitle,"ParameterValue",$_.MainWindowTitle)
                }
        })]
        [int[]]$ProcessID = $PID,
        [ValidateScript({Test-Path $_})]
        [string]$DirectoryPath = [Environment]::GetFolderPath("MyPictures"),
        [Parameter(ParameterSetName="AllProcesses")]
        [switch]$AllWindows,
        [switch]$MinmizeWindows
    )
    Begin{
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName Microsoft.VisualBasic

        # User32 DLL call import
        Add-Type @"
            using System;
            using System.Text;
            using System.Collections.Generic;
            using System.Runtime.InteropServices;

            public class Win32 {
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool SwitchToThisWindow(IntPtr hWnd, bool Unknown);
            }
            public struct RECT
            {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
            }
"@
    $DirectoryPath = $DirectoryPath.TrimEnd('\')      
    $AppWindow = New-Object Rect
    if ($AllWindows){
        $ProcessID = (Get-Process | where MainWindowTitle -ne "").Id
    }

    }# Begin

    Process{
        foreach ($App in $ProcessID){
            try{
                $currentProcess = Get-Process -Id $App -ErrorAction Stop
                $Handle = $currentProcess.MainWindowHandle
                if ($currentProcess.MainWindowTitle -eq ""){
                    Write-Error "No Window to Show." -ErrorAction Stop
                }
            }
            catch{
                Write-Warning "Either App is no longer running or it does not a window open"
                continue
            }
            $Title = $currentProcess.MainWindowTitle
            [System.IO.Path]::GetInvalidFileNameChars() | foreach {$Title = $Title.Replace("$_","")}
            $FileName = (Get-Date -Format MM-dd-yyyy_mm_ss) + $Title
            if ($AppWindow.Left -lt -1000){
                try{
                    $ActivateWindow = [win32]::ShowWindow($Handle,5)
                    Start-Sleep -Milliseconds 750
                    [void][Win32]::SwitchToThisWindow($Handle,$true)
                    [void][Win32]::GetWindowRect($Handle,[ref]$AppWindow)
                    if (!($ActivateWindow -or ($AppWindow.Left -lt -1000))){
                        Write-Error -Message "Unable to display window." -ErrorAction Stop
                    }
                }
                catch{
                    Write-Warning "Unable to display window."
                    Continue
                }
            }
            else{
                [void][win32]::ShowWindow($Handle,5)
                [void][Win32]::SwitchToThisWindow($Handle,$true)
                [Microsoft.VisualBasic.Interaction]::AppActivate($App)
            }
            Start-Sleep -Milliseconds 1000
            [void][Win32]::GetWindowRect($Handle,[ref]$AppWindow)
            $Bitmap = [System.Drawing.Bitmap]::new(($AppWindow.Right - $AppWindow.Left),($AppWindow.Bottom - $AppWindow.Top))
            $Graphic = [System.Drawing.Graphics]::FromImage($bitmap)
            $Graphic.CopyFromScreen($AppWindow.Left, $AppWindow.Top, 0, 0, $bitmap.Size)
            $Bitmap.Save("$DirectoryPath\$FileName.bmp")
            if ($MinmizeWindows){
                [void][win32]::ShowWindow($Handle,6)
            }
        } #foreach
    } #Process
}