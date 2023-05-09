<#
.SYNOPSIS
    This script monitoring $logFile parameter log file and restart pyton script if it hang
.LINK
    https://github.com/alhaos/PytonScriptMonitoring
.EXAMPLE
    script.ps1 -Delay 20 -Logfile c:\tmp\example.log -PytonScriptPath c:\tmp\example.py
    
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Delay,

    [Parameter(Mandatory)]
    [string]
    $Logfile,

    [Parameter(Mandatory)]
    [string]
    $PytonScriptPath
)

class TargetLine {
    [datetime]$Dt
    [string]$Message
}

$DebugPreference = 'Continue'
$ErrorActionPreference = 'Stop'

function Get-LastLineWithTime {
    param (
        [string]$LogFileName
    )
 
    $line = (Get-Content $LogFileName -Tail 10)[-1]
   
    return [TargetLine]@{
        Dt      = [datetime]::ParseExact($line.Substring(1, 19), 'yyyy-MM-dd hh:mm:ss', $null)
        Message = $line.Substring(22)
    }
}

function Restart-Prcess {
    stop-process -id $id
    Remove-Item $Logfile -Confirm:$false
    $id = (Start-Process python -ArgumentList $PytonScriptPath -PassThru).Id
}


$ID = (Start-Process python -ArgumentList $Name -PassThru).Id

while ($true) {
    
    Start-Sleep $Delay

    if (Test-Path $Logfile) {
        continue
    }

    $targetLine = Get-LastLineWithTime $Logfile
    
    if ($targetLine.Dt -lt [datetime]::Now.AddMinutes( - ($Delay))) {    
        continue
    }

    switch -regex ($targetLine.Message) {
        "Загрузка файла на сервер..." { 
            Restart-Prcess
            continue
        }
        "DOWNLOAD.*" { 
            Restart-Prcess
            continue
        }
        "New link from NONE. Waiting..." {
            Restart-Prcess
            continue
        }
    }
}

