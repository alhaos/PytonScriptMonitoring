<#
.SYNOPSIS
    This script monitoring $logFile parameter log file and restart pyton script if it hang
.LINK
    https://github.com/alhaos/PytonScriptMonitoring
.EXAMPLE
    script.ps1 -Delay 20 -Logfile c:\tmp\example.log -PytonScriptPath c:\tmp\example.py -StockDirecory c:\tmp\StockDirecory
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
    $PytonScriptPath,

    [Parameter(Mandatory)]
    [string]
    $StockDirecory
)

class TargetLine {
    [datetime]$Dt
    [string]$PrvMessage
    [string]$Message
}

$DebugPreference = 'Continue'
$ErrorActionPreference = 'Stop'

function Get-LastLineWithTime {
    param (
        [string]$LogFileName
    )
 
    $prvLine = (Get-Content $LogFileName -Tail 10)[-2]
    $line = (Get-Content $LogFileName -Tail 10)[-1]
   
    return [TargetLine]@{
        Dt      = [datetime]::ParseExact($line.Substring(1, 19), 'yyyy-MM-dd hh:mm:ss', $null)
        PrvMessage = $prvLine.Substring(22)
        Message = $line.Substring(22)
    }
}

function Restart-Prcess {
    stop-process -id $id
    Remove-Item $Logfile -Confirm:$false
    $id = (Start-Process python -ArgumentList $PytonScriptPath -PassThru).Id
}

function StockDirecoryReload {
    $StockDataDirecory = Join-Path $StockDirecory -ChildPath "data"
    Get-ChildItem $StockDataDirecory -File | Remove-Item -Confirm:$false
    Get-ChildItem $StockDirecory -Filter "*.zip" | ForEach-Object {
        Expand-Archive $_ $StockDataDirecory
    }
}

$ID = (Start-Process python -ArgumentList $PytonScriptPath -PassThru).Id

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
            if ($targetLine.PrvMessage -match "Загрузка файла на сервер..." -or $targetLine.PrvMessage -match "DOWNLOAD.*"){
                Restart-Prcess
                continue
            }
        }
    }
}

