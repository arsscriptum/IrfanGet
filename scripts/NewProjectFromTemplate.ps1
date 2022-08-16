<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍 
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/  
#>

[CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$true, Position=1)]
        [String]$ProjectName,
        [Parameter(Mandatory=$false)]
        [String]$TemplatePath = "$PSScriptRoot\Template",
        [Parameter(Mandatory=$false)]
        [switch]$Overwrite
    )  


#===============================================================================
# ChannelProperties
#===============================================================================

class MyScriptLogProperties
{
    #ChannelProperties
    [string]$Channel = 'PROJECT GENERATE'
    [ConsoleColor]$TitleColor = 'Magenta'

    [ConsoleColor]$MessageColor = 'Gray'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}

$Script:LogProps = [MyScriptLogProperties]::new()


function LogMessage{                
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [switch]$Test,
        [Alias('n')]
        [switch]$NoNewLine,
        [Alias('d')]
        [switch]$Detailed
    )

    if($Detailed){
        if($Script:Verbose -eq $False){
            return    
        }
    }
    if($Test){
        Write-Host "[TESTMODE] " -f DarkMagenta -NoNewLine
        Write-Host "$Message" -f 'DarkGray' -NoNewLine:$NoNewLine
    }else{
        if($Detailed){
            Write-Host "[$($Script:LogProps.Channel) VERBOSE] " -f 'Cyan' -NoNewLine
        }else{
            Write-Host "[$($Script:LogProps.Channel)] " -f $($Script:LogProps.TitleColor) -NoNewLine
        }
        Write-Host "$Message" -f $($Script:LogProps.MessageColor) -NoNewLine:$NoNewLine
    }
    
    
}



function LogResult{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [switch]$Ok
    )

    if($Ok -eq $True){
        Write-Host "[$($Script:LogProps.Channel)] " -f $($Script:LogProps.TitleColor) -NoNewLine
        Write-Host "SUCCESS " -f $($Script:LogProps.SuccessColor) -NoNewLine
    }else{
        Write-Host "[$($Script:LogProps.Channel)] " -f $($Script:LogProps.ErrorColor) -NoNewLine
        Write-Host "ERROR " -f $($Script:LogProps.ErrorDescriptionColor) -NoNewLine
    }
    
    Write-Host "$Message" -f $($Script:LogProps.MessageColor)
}


function LogError{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$ExceptMsg
    )       

    Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
}  


function ShowExceptionDetails{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg" -ForegroundColor DarkYellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor DarkGreen
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--" -ForegroundColor DarkGreen       
    }
}  


try{
    $Script:Verbose = $False
    if($PSBoundParameters.ContainsKey('Verbose')){
        $Script:Verbose = $True
    }elseif($Verbose -eq $Null){
        $Script:Verbose = $False
    }

    $ErrorOccured = $False
    $TestMode = $False
    if($PSBoundParameters.ContainsKey('WhatIf')){
        LogMessage "TESTMODE ENABLED"
        $TestMode = $true
    }

    $BuildCfgFile = Join-Path $TemplatePath "buildcfg.ini"
    $ProjectFile = Join-Path $TemplatePath "vs\_PROJECTNAME_.vcxproj"
    $FiltersFile = Join-Path $TemplatePath "vs\_PROJECTNAME_.vcxproj.filters"
    $ConfigsFile = Join-Path $TemplatePath "vs\cfg\winapp.props"
    $DejaInsFile = Join-Path $TemplatePath "vs\cfg\dejainsight.props"

    $NewBuildCfgFile = Join-Path $Path "buildcfg.ini"
    $NewProjectFile = Join-Path $Path "vs\$($ProjectName).vcxproj"
    $NewFiltersFile = Join-Path $Path "vs\$($ProjectName).vcxproj.filters"
    $NewConfigsFile = Join-Path $Path "vs\cfg\winapp.props"
    $NewDejaInsFile = Join-Path $Path "vs\cfg\dejainsight.props"

    $ProjectFiles = @($BuildCfgFile,$ProjectFile, $FiltersFile, $ConfigsFile, $DejaInsFile)
    $NewProjectFiles = @($NewBuildCfgFile,$NewProjectFile, $NewFiltersFile, $NewConfigsFile, $NewDejaInsFile )
    
    $Guid = (New-Guid).Guid
    $Guid = "{$Guid}"



    For($x = 0 ; $x -lt $NewProjectFiles.Count ; $x++){
        $newfile = $NewProjectFiles[$x]
        if(Test-Path -Path $newfile -PathType Leaf){
            if($Overwrite){
                Remove-Item "$NewProjectFiles[$y]" -Force -ErrorAction Ignore | Out-Null ; LogMessage "DELETED `"$NewProjectFiles[$y]`"" -d;
                continue;
            }
            LogMessage "Overwrite `"$newfile`" (y/n/a) " -n
            $a = Read-Host '?'
            while(($a -ne 'y') -And ($a -ne 'n') -And ($a -ne 'a')){
                LogMessage "Please enter `"y`" , `"n`" or `"a`""
                LogMessage "Overwrite `"$newfile`" (y/n/a) " -n
                $a = Read-Host '?'
            }
            if($a -eq 'a'){  
                For($y = 0 ; $y -lt $NewProjectFiles.Count ; $y++){
                    Remove-Item "$NewProjectFiles[$y]" -Force -ErrorAction Ignore | Out-Null ; LogMessage "DELETED `"$NewProjectFiles[$y]`"" -d;
                }
                break;
            }
            elseif($a -ne 'y'){ throw "File $newfile already exists!" ; }else{ Remove-Item $newfile -Force -ErrorAction Ignore | Out-Null ; LogMessage "DELETED `"$newfile`"" -d;}
        }
    }
    For($x = 0 ; $x -lt $ProjectFiles.Count ; $x++){
        $file = $ProjectFiles[$x]
        $newfile = $NewProjectFiles[$x]
        LogMessage "Processing '$file'" -d
        $Null = Remove-Item -Path $newfile -Force -ErrorAction Ignore
        $Null = New-Item -Path $newfile -ItemType File -Force -ErrorAction Ignore
        $exist = Test-Path -Path $file -PathType Leaf
        if($Verbose){
            LogResult "CHECKING FILE `"$file`"" -Ok:$exist
        }

        
        if($exist -eq $False){    
            throw "Missing $file"
        }
        

        LogMessage "Get-Content -Path $file -Raw" -d
        $FileContent = Get-Content -Path $file -Raw
        if($FileContent -eq $null){ throw "INVALID File $file" }

        LogMessage "`$FileContent.IndexOf('_PROJECTNAME_')" -d
        $i = $FileContent.IndexOf('_PROJECTNAME_')
        if($i -ge 0){
            LogMessage "Replacing '_PROJECTNAME_' to '$ProjectName'" -d
            $FileContent = $FileContent -Replace '_PROJECTNAME_', $ProjectName    
        }
        $i = $FileContent.IndexOf('_PROJECTGUID_')
        if($i -ge 0){
            LogMessage "Replacing '_PROJECTGUILD_' to '$Guid'" -d
            $FileContent = $FileContent -Replace '_PROJECTGUID_', $Guid
        }
        
        LogMessage "Saving '$newfile'"
        Set-Content -Path $newfile -Value $FileContent
    }
    
}catch{
    $ErrorOccured = $True
    ShowExceptionDetails $_ -ShowStack
}finally{
    if($ErrorOccured -eq $False){
        Write-Host "`n[SUCCESS] " -ForegroundColor DarkGreen -n
        if($TestMode){
            Write-Host "test success! You can rerun in normal mode" -ForegroundColor Gray
        }else{
            Write-Host "Project generated in $Path" -ForegroundColor Gray    
            $exp = (Get-Command 'explorer.exe').Source
            &"$exp" "$Path"
        }
    }else{
        Write-Host "`n[FAILED] " -ForegroundColor DarkRed -n
        Write-Host "Script failure" -ForegroundColor Gray
    }
}





        
        
    