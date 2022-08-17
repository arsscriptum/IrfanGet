<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍 
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/  
#>



$Global:DevelopmentRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$Global:ProjectRoot = (Resolve-Path -Path "$PSScriptRoot\..").Path
$Global:ToolsRoot = (Resolve-Path -Path "$PSScriptRoot\tools").Path

$Global:BuildAutomationRoot = Join-Path $Global:DevelopmentRoot 'BuildAutomation' 
$Global:BA_SetupScriptPath = Join-Path $Global:BuildAutomationRoot 'Setup.ps1' 
$Global:DejaInsightRoot = Join-Path $Global:DevelopmentRoot 'DejaInsight' 
$Global:Dependencies = @('BuildAutomation','DejaInsight')
$Global:WindowsGit = Join-Path $Global:ToolsRoot 'WindowsGit.ps1'


. "$Global:WindowsGit"

function Initialize-ProjectDependencies{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if($PSBoundParameters.ContainsKey('WhatIf')){
        LogMessage "TEST MODE ENABLED" -Test
        $TestMode = $true
    }
    pushd $Global:DevelopmentRoot
    ForEach($d in $Global:Dependencies){
        $LocalPath = Join-Path $Global:DevelopmentRoot $d
        $formatstring = "https://github.com/arsscriptum/{0}.git"
        $fields = $d
        $DepCloneUrl=($formatstring -f $fields)

        if(Test-Path -Path "$LocalPath" -PathType 'Container'){
            $Null = Remove-Item -Path $LocalPath -Recurse -Force -ErrorAction Ignore   
        }

        
        if(-not $TestMode){
            Write-Log "cloning $d" 
            Write-Verbose "[$GitPath clone $DepCloneUrl -recurse]"
            &"$GitPath" "clone" "$DepCloneUrl" "--recurse"

        }
        
    }

    if(Test-Path -Path "$($Global:BA_SetupScriptPath)" -PathType 'Leaf'){
        $ScriptPath = (Get-Item -Path "$($Global:BA_SetupScriptPath)").DirectoryName
        pushd $ScriptPath
        . "$Global:BA_SetupScriptPath"
        popd
    }else{
        throw "MISSING Setup Script"
    }
}
