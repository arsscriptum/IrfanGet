<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   
#̷𝓍   Download files from fosshub website, using a script. Can be used to automate Downloading app and plugins.
#̷𝓍   
#̷𝓍   I wrote this to help this dude on Reddit:
#̷𝓍   https://www.reddit.com/r/PowerShell/comments/u3ge6a/download_files_from_fosshub_website
#̷𝓍   
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/
#̷𝓍   
#̷𝓍   Run it ./GetIrFanView.ps1
#̷𝓍   will download both the app and the plugins.
#>

[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$DownloadPath = "$($PWD.Path)\IrFan",
        [Parameter(Mandatory=$false)]
        [switch]$Overwrite
    )  

try{

    $FilesToDownload = @('iview460_x64_setup.exe','iview460_plugins_x64_setup.exe')

    $Result = $False
    $TestMode = $False
    if($PSBoundParameters.ContainsKey('WhatIf')){
        Write-Host "TEST MODE ENABLED" -f DarkRed
        $TestMode = $true
    }
    
    $DependenciesPath = "$PSScriptRoot\tools"
    $DependencyScript = Join-Path $DependenciesPath "IrFanFuncs.ps1"
    

    if(Test-Path -Path $DependencyScript -PathType Leaf){
        Write-Host "✅ Dependency include $DependencyScript"
        . "$DependencyScript"

        $FunctionList = [System.Collections.ArrayList]::new()
        $FunctionPattern = "function\s\w+-\w+"              
        $StrList = ( Get-Content -Path $DependencyScript | Select-String -Pattern $FunctionPattern )  
        #$StrList = ( Get-ChildItem -Path $DependenciesPath -Filter '*.ps1' | Select-String -Pattern $FunctionPattern )
        foreach($s in $StrList){
            [string]$fname = $s ; 
            $fname = $fname.substring(9, $fname.Length - 1 - 9);
            $Null = $FunctionList.Add($fname)

        }   
    }else{
        throw "Missing $DependencyScript"
    }
    
    foreach($f in $FunctionList){
        $cmd = Get-Command $f
        if($cmd -eq $Null){
            throw "missing dependency: $cmd"
        }else{
            Write-Host "✅ Dependency check [$cmd]"
        }
    }


    if($Overwrite){
        LogMessage "-Overwrite: clean $DownloadPath"
        $Null = Remove-Item -Path $DownloadPath -Recurse -Force -ErrorAction Ignore
    }

    if(Test-Path -Path $DownloadPath){
        $Files = (gci -Path $DownloadPath)
        $FilesCount = $Files.Count
        if($FilesCount -gt 0){
            LogError "Directory $DownloadPath already exists, and NOT empty. (delete, or use -Overwrite)"
            return    
        }
    }

    LogMessage "Download file to `"$DownloadPath`" (y/n) " -n
    $a = Read-Host '?'
    while(($a -ne 'y') -And ($a -ne 'n')){
        LogMessage "Please enter `"y`" or `"n`""
        LogMessage "Download file to `"$DownloadPath`" (y/n) " -n
        $a = Read-Host '?'
    }
    if($a -ne 'y'){ throw "Need Download Folder Confirmation. User said NO" ; }
    LogMessage "Create Directory $DownloadPath"
    $Null = New-Item -Path $DownloadPath -ItemType "Directory" -Force -ErrorAction Ignore

    
    ForEach($Filename in $FilesToDownload){
        # ------------------------------
        # iview460_x64 APP
        
        LogMessage "Download $Filename"
        $DestinationPath = Join-Path $DownloadPath $Filename
        $Result = Invoke-IRFanDownloadFile $DestinationPath $Filename -Test:$TestMode
        if($Result -eq $False){
            throw "Failure on IRFanDownloadFile $DestinationPath $Filename"
        }
    }
    
    
}catch{
    $Result = $False
    $formatstring = "{0}`n{1}"
    $fields = $_.FullyQualifiedErrorId,$_.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    Write-Host "[ERROR] " -f DarkRed -NoNewLine
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
}finally{
    if($Result){
        Write-Host "`n[SUCCESS] " -ForegroundColor DarkGreen -n
        if($TestMode){
            Write-Host "test success! You can rerun in normal mode" -ForegroundColor Gray
        }else{
            Write-Host "Downloaded all files to $DownloadPath" -ForegroundColor Gray    
            $exp = (Get-Command 'explorer.exe').Source
            &"$exp" "$DownloadPath"
        }
        
    }else{
        Write-Host "`n[FAILED] " -ForegroundColor DarkRed -n
        Write-Host "Script failure" -ForegroundColor Gray
    }
}