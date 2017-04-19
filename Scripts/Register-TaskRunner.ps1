function Register-TaskRunner {
<#
.SYNOPSIS
Watch changing file and run any tasks.

.DESCRIPTION
Powershell task runner

.EXAMPLE
$parent = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Register-Watcher -Folder $parent

.NOTES
https://msdn.microsoft.com/ja-jp/library/system.io.filesystemwatcher(v=vs.110).aspx  
https://mcpmag.com/articles/2015/09/24/changes-to-a-folder-using-powershell.aspx?m=1

#>
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory=$true)]
      [string]$Folder,
      
      [Parameter(Mandatory=$false)]
      [string]$Filter = "*.ps1"
    )    

    $VerbosePreference = "Continue"
    $events = Get-EventSubscriber
    foreach ($event in $events) {
        if ($event.EventName -eq "Changed" -and $Folder -eq $event.SourceObject.Path) { 
            Write-Verbose "already exist the event."
            return
        }
    }
    
    $Watcher = New-Object IO.FileSystemWatcher -Property @{ 
        Path = $Folder
        Filter = $Filter
        IncludeSubdirectories = $false
        EnableRaisingEvents = $true
    }

    $changeAction = [scriptblock]::Create('
        $path = $Event.SourceEventArgs.FullPath
        $changedFileName = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated  
        $testScript = $changedFileName -replace ".ps1", ".Tests.ps1"  
        $testFullPath = "$($Event.MessageData)\$testScript"
        Write-Host "The file $changedFileName was $changeType at $timeStamp"
        if (Test-Path $testFullPath) { 
            Write-Host "Running $testScript" -BackgroundColor DarkGray       
            . $testFullPath
        } else {
            Write-Host "not exist $testScript" -BackgroundColor DarkGray       
        }
    ')

    Register-ObjectEvent -InputObject $Watcher `
                         -EventName "Changed" `
                         -Action $changeAction `
                         -MessageData $Folder
}
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Register-TaskRunner -Folder $here