<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍 
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/  
#>


function Get-GitPath{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $GitPath = $Null
    try{
       
        $GitCmd = (Get-Command 'git.exe')
        if($GitCmd -eq $Null) { throw "cannot find git";}
        $GitPath = $GitCmd.Source
    }catch{
        Show-ExceptionDetails $_
    }
    return $GitPath 
}


function Request-GitClone{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false)]
        [string]$LocalPath,
        [Parameter(Mandatory=$false)]
        [string]$WorkingDirectory = "$PSScriptRoot",
        [Parameter(Mandatory=$false)]
        [switch]$Recurse
    )  
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $GitPath = Get-GitPath
        $CurrentTime = Get-Date -uformat %s
        $FNameOut = "$ENV:Temp\pout.$CurrentTime.log"
        $FNameErr = "$ENV:Temp\perr.$CurrentTime.log"
        $startProcessParams = @{
            FilePath               = $GitPath
            RedirectStandardError  = $FNameErr
            RedirectStandardOutput = $FNameOut
            Wait                   = $true
            PassThru               = $false
            NoNewWindow            = $true
            WorkingDirectory       = $WorkingDirectory
        }

        [string[]]$ArgumentList = @("clone", "$Url")
        if($Recurse){
            $ArgumentList += "--recurse"
        }
        $LogCommand = "Start-Process '$GitPath' "
        $LogArgs | % { $LogCommand += $_ ;$LogCommand += ' ' ;}
     
            write-Host "WHATIF [$WhatIf] $LogCommand"  
            
        Write-Host "[GIT] " -f DarkRed -n
        Write-Host "Cloning $Url..." -f DarkYellow
        Write-Verbose "Executing '$LogCommand'"
        Write-Verbose "RedirectStandardError to $FNameErr"
        Write-Verbose "RedirectStandardOutput to $FNameOut"
             
        [System.Diagnostics.Process]$cmd = Start-Process @startProcessParams -ArgumentList $ArgumentList
        $cmdExitCode = $cmd.ExitCode
        $cmdId = $cmd.Id 
        $cmdHasExited=$cmd.HasExited 
        $stopwatch.Stop()
        $res = [PSCustomObject]@{
            Id                 = $cmdId
            ExitCode           = $cmdExitCode
            Output             = $stdOut
            Error              = $stdErr
            ElapsedSeconds     = $stopwatch.Elapsed.Seconds
            ElapsedMs          = $stopwatch.Elapsed.Milliseconds
        }
        $stdOut = Get-Content -Path $FNameOut -Raw
        $stdErr = (Get-Content -Path $FNameErr)
        $stdErr = $stdErr[$stdErr.Count-1]
        if ([string]::IsNullOrEmpty($stdOut) -eq $false) {
            $stdOut = $stdOut.Trim()
        }
        if ([string]::IsNullOrEmpty($stdErr) -eq $false) {
            $stdErr = $stdErr.Trim()
        }
        Write-Verbose "stdout ==> $stdOut"
        Write-Verbose "stderr ==> $stdErr"
        if($cmdExitCode -eq 0){
            Write-Host "[GIT] " -f DarkRed -n
            Write-Host "SUCCESS [$($stopwatch.Elapsed.Seconds).$($stopwatch.Elapsed.Milliseconds)s]" -f DarkYellow
        }else{
            Write-Host "[GIT] " -f DarkRed -n
            Write-Host "Clone error ($stdErr)" -f DarkYellow
        }
        
        return $cmdExitCode
    }catch{
        Write-Error $_
    }
}

