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




#===============================================================================
# ChannelProperties
#===============================================================================

class MyScriptLogProperties
{
    #ChannelProperties
    [string]$Channel = 'IRFAN'
    [ConsoleColor]$TitleColor = 'DarkCyan'

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
        [switch]$NoNewLine
    )

    if($Test){
        Write-Host "[TESTMODE] " -f DarkMagenta -NoNewLine
        Write-Host "$Message" -f 'DarkGray' -NoNewLine:$NoNewLine
    }else{
        Write-Host "[$($Script:LogProps.Channel)] " -f $($Script:LogProps.TitleColor) -NoNewLine
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
        Write-Host "[$($Script:LogProps.Channel)] " -f $($Script:LogProps.SuccessColor) -NoNewLine
        Write-Host " SUCCESS " -f $($Script:LogProps.SuccessColor) -NoNewLine
    }else{
        Write-Host "[$($Script:LogProps.Channel)] " -f $($Script:LogProps.ErrorColor) -NoNewLine
        Write-Host " ERROR " -f $($Script:LogProps.ErrorDescriptionColor) -NoNewLine
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

    Write-Host "`n[ERROR] " -NoNewLine -ForegroundColor DarkRed; 
    Write-Host "$ExceptMsg" -ForegroundColor DarkYellow
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

function Get-IRFanDownloadUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$FileName = 'iview460_plugins_x64_setup.exe',
        [Parameter(Mandatory=$false)]
        [string]$ReleaseId = '623457812413750bd71fef36',
        [Parameter(Mandatory=$false)]
        [string]$ProjectId = '5b8d1f5659eee027c3d7883a',
        [Parameter(Mandatory=$false)]
        [switch]$TestMode
    )  
    if($PSBoundParameters.ContainsKey('WhatIf')){
        LogMessage "TEST MODE ENABLED" -Test
        $TestMode = $true
    }

    try{
        $Url = 'https://api.fosshub.com/download'
        $Params = @{
            Uri             = $Url
            Body            = @{
                projectId  = "$ProjectId"
                releaseId  = "$ReleaseId"
                projectUri = 'IrfanView.html'
                fileName   = "$FileName"
                source     = 'CF'
            }

            Headers         = @{
                'User-Agent'          = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36'
            }
            Method          = 'POST'
            UseBasicParsing = $true
        }
        Write-Verbose "Invoke-WebRequest $Params"
        $Data = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json
        $ErrorType = $Response.error
        if($ErrorType -ne $Null){
            throw "ERROR RETURNED $ErrorType"
            return $Null
        }

        $Res = $Data.data.url
        if($TestMode){
            LogMessage "Get the Download URL for $FileName" -Test:$TestMode
            LogMessage "Result ==> $Res" -Test:$TestMode    
        }
        
        return $Res
    }catch{
        Write-Error $_
    }
}


function Invoke-IRFanDownloadFile{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$DestinationPath,
        [Parameter(Mandatory=$false, Position=1)]
        [string]$FileName = 'iview460_plugins_x64_setup.exe',
        [Parameter(Mandatory=$false)]
        [switch]$Test
    ) 
  try{

    if($PSBoundParameters.ContainsKey('WhatIf')){
        LogMessage "TEST MODE ENABLED" -Test
        $TestMode = $true
    }

    [uri]$UriData = (Get-IRFanDownloadUrl -FileName $FileName -Test:$Test)

    if($TestMode){
        $Server = $UriData.Host
        $TcpPort = $UriData.Port
        LogMessage "NO DOWNLOAD TEST CONNECTION ONLY" -Test
        $Connect = Test-Connection -TargetName $Server -TcpPort $TcpPort -IPv4 -Quiet
        LogMessage "Testing Connection to $Server $TcpPort ==> $Connect" -Test
        return $Connect
    }

    $Url = $UriData.AbsoluteUri
    $Script:ProgressTitle = 'STATE: DOWNLOAD'
    
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.PreAuthenticate = $false
    $request.Method = 'GET'

    $request.Headers.Add('sec-ch-ua', '" Not A;Brand";v="99", "Chromium";v="99", "Google Chrome";v="99"')
    $request.Headers.Add('sec-ch-ua-mobile', '?0')
    $request.Headers.Add('sec-ch-ua-platform', "Windows")
    $request.Headers.Add('Upgrade-Insecure-Requests', '1')
    $request.Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36')
    $request.Headers.Add('Sec-Fetch-Site', 'same-site')
    $request.Headers.Add('Sec-Fetch-Mode' ,'navigate')
    $request.Headers.Add('Sec-Fetch-Dest','document')
    $request.Headers.Add('Referer' , 'https=//www.fosshub.com/')
    $request.Headers.Add('Accept-Encoding', 'gzip, deflate, br')

    $request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
    $request.KeepAlive = $true
    $request.Timeout = ($TimeoutSec * 1000)
    $request.set_Timeout(15000) #15 second timeout

    try{
        $response = $request.GetResponse()    
    }catch{
        LogError "HTTPS Request Error"
        Write-Host "=== BEGIN REQUEST ===" -f Yellow
        Write-Host "GET $Url" -f Gray
        Write-Host "=== END REQUEST ===" -f Yellow
        return $False
    }
    
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $totalLengthBytes = [System.Math]::Floor($response.get_ContentLength())
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $DestinationPath, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $dlkb = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $dlkb = $([System.Math]::Floor($downloadedBytes/1024))
       $msg = "Downloaded $dlkb Kb of $totalLength Kb"
       $perc = (($downloadedBytes / $totalLengthBytes)*100)
       if(($perc -gt 0)-And($perc -lt 100)){
         Write-Progress -Activity $Script:ProgressTitle -Status $msg -PercentComplete $perc 
       }
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
    Write-Error $_
    return $false
  }
  return $True
}

