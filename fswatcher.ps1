Start-Job -Name ListenerJob -ScriptBlock {
    function changedHandler {
    param (
        [Object]$Sender,
        [Object]$EventArgs
    )
    $Sender
    $EventArgs
    }

    function createdHandler {
        param (
            [Object]$Sender,
            [Object]$EventArgs
        )
        Write-Host "createdHandler"
        $Sender
        $EventArgs
    }
    function renamedHandler {
        param (
            [Object]$Sender,
            [Object]$EventArgs
        )
        $Sender
        $EventArgs
    }
    function deletedHandler {
        param (
            [Object]$Sender,
            [Object]$EventArgs
        )
        $Sender
        $EventArgs
    }
    function errorHandler {
        param (
            [Object]$Sender,
            [Object]$EventArgs
        )
        $Sender
        $EventArgs
    }
    function disposedHandler {
        param (
            [Object]$Sender,
            [Object]$EventArgs
        )
        $Sender
        $EventArgs
    }
    $fsWatcher = [System.IO.FileSystemWatcher]::new("C:\temp")
    Register-ObjectEvent -InputObject $fsWatcher -EventName Created -SourceIdentifier createdEvent -Action { createdHandler } 
    Register-ObjectEvent -InputObject $fsWatcher -EventName Deleted -SourceIdentifier deletedEvent -Action { deletedHandler } 
    Register-ObjectEvent -InputObject $fsWatcher -EventName Renamed -SourceIdentifier renamedEvent -Action { renamedHandler } 
    Register-ObjectEvent -InputObject $fsWatcher -EventName Changed -SourceIdentifier changedEvent -Action { changedHandler } 
    Register-ObjectEvent -InputObject $fsWatcher -EventName Disposed -SourceIdentifier disposedEvent -Action { disposedHandler } 
    Register-ObjectEvent -InputObject $fsWatcher -EventName Error -SourceIdentifier errorEvent -Action { errorHandler } 
    While ($True) {
        $fsWatcher.WaitForChanged([System.IO.WatcherChangeTypes]::All)
    }
    Write-Host "should be done"
    Unregister-ObjectEvent createdEvent
    Unregister-ObjectEvent deletedEvent
    Unregister-ObjectEvent renamedEvent
    Unregister-ObjectEvent changedEvent
    Unregister-ObjectEvent disposedEvent
    Unregister-ObjectEvent errorEvent
}
