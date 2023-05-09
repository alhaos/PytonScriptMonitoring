<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

[CmdletBinding()]
param (

    [Parameter(Mandatory = $true)]
    [int]
    $TimeSpan1,

    [Parameter(Mandatory = $true)]
    [int]
    $TimeSpan2,

    [Parameter(Mandatory = $true)]
    [string]
    $Name, 

    [Parameter(Mandatory = $true)]
    [string]
    $targetPath = "$targetPath"
)

Clear-Host
Push-Location $targetPath

$id = (Start-Process python -ArgumentList $Name -PassThru).Id

while (!(Test-Path "$targetPath\logs.txt")) {
    Start-Sleep -s $TimeSpan1
}

do {
    while (!(Test-Path "$targetPath\logs.txt")) {
        Start-Sleep -s $TimeSpan1
    } 
        
    if (!$linenumber) {

        do {
            $linenumber = (Get-ChildItem "$targetPath\logs.txt" | Select-String 'Отправка файла' | Select-Object -Last 1).linenumber
            Start-Sleep -Seconds $args[0]
        }
        while (!$linenumber)
        Start-Sleep -Seconds $TimeSpan2
        $data = Get-Content "$targetPath\logs.txt" -encoding utf8
        if (!$data[$linenumber]) {
            "$(get-date) - ошибка, перезапуск скрипта"
            #stop-process -id (Get-WmiObject Win32_process | where {($_.name -like '*python*') -and ($_.commandline -like "*$($args[2])`"*")}).processid
            stop-process -id $id
            Remove-Item "$targetPath\logs.txt" -Confirm:$false
            $linenumber = $null
            $id = (Start-Process python -ArgumentList "$($args[2])" -PassThru).Id
        }

    }
    else {

        $linenumber = (Get-ChildItem "$targetPath\logs.txt" | Select-String 'Отправка файла' | select -Last 1).linenumber
        Start-Sleep -Seconds $args[1]
        $data = Get-Content "$targetPath\logs.txt" -encoding utf8
        if (!$data[$linenumber]) {
            "$(get-date) - ошибка, перезапуск скрипта"
            #stop-process -id (Get-WmiObject Win32_process | where {($_.name -like '*python*') -and ($_.commandline -like "*$($args[2])`"*")}).processid
            stop-process -id $id
            Remove-Item "$targetPath\logs.txt" -Confirm:$false
            $linenumber = $null
            $id = (Start-Process python -ArgumentList "$($args[2])" -PassThru).Id
            continue
        }
        $linenumber_2 = (Get-ChildItem "$targetPath\logs.txt" | Select-String 'New link from NONE. Waiting...' | select -Last 1).linenumber
        if ($linenumber_2) {
            Start-Sleep -Seconds $args[1]
            $data = Get-Content "$targetPath\logs.txt" -encoding utf8
            if (!$data[$linenumber_2]) {
                "$(get-date) - ошибка, перезапуск скрипта"
                stop-process -id $id
                Remove-Item "$targetPath\logs.txt" -Confirm:$false
                $linenumber_2 = $null
                $id = (Start-Process python -ArgumentList "$($args[2])" -PassThru).Id
            }
        }
    }
   
} while (1 -gt 0)