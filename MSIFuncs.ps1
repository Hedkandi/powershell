# Ref: http://www.laurierhodes.info/?q=node/104

$WixInstallerDLL = "C:\Program Files (x86)\WiX Toolset v4.0\bin\WixToolset.Dtf.WindowsInstaller.dll"
if (Test-Path -Path "FileSystem::$WixInstallerDLL") {
    Add-Type -Path $WixInstallerDLL -ErrorAction Stop
}
else {
    throw "Failed to open WixToolset.Dtf.WindowsInstaller.dll"
}

function Get-MsiProperty {
    param(
        [ValidateScript({(Test-Path -Path $_)})]
        [ValidateNotNullOrEmpty()]
        [string]$MsiDatabasePath,
        [ValidateNotNullOrEmpty()]
        [string]$Property
    )
    $msiDatabase = Get-MSIDatabase -Path $MsiDatabasePath
    $ReturnProperty = "$((Get-MSITableContents -MSIDatabase $MsiDatabasePath -Query "SELECT Value FROM Property WHERE Property = '$Property'").Value)"
    Close-MSIDatabase -Database $msiDatabase
    return $ReturnProperty
}

function Get-MSIDatabase {
    param(
        $Path
    )
    $MSIDatabase = New-Object WixToolset.Dtf.WindowsInstaller.Database($Path);
    if (-not $MSIDatabase.Handle) {
        throw "Failed to open file."
    }
    return $MSIDatabase
}

function Close-MSIDatabase {
    param(
        $MSIDatabase
    )
    $MSIDatabase.Close()
}

function Get-MSITableContents {
    param(
        $MSIDatabase,
        [string]$Query
    )
    [WixToolset.Dtf.WindowsInstaller.View]$oView = $MSIDatabase.OpenView($Query)
    $oView.Execute()

    while ($oRecord = $oView.Fetch()) {
        $row = New-Object psobject
        foreach ($col in $oView.Columns) {
            Write-Debug "$($col.Name) $($col.Type)"
            if ($col.Type -match "string") {
                $row | Add-Member $col.Name $oRecord.GetString($col.Name)
            }
            elseif ($col.Type -match "int") {
                $row | Add-Member $col.Name $oRecord.GetInteger($col.Name)
            }
        }
        Write-Output $row
        #$worker.ReportProgress()
    }
    #$TableData.Add("Rows",$TableRows)
    #Write-Host $TableData
    #$Global:FileInfo.Tables | Add-Member $Table $TableData
    $oView.Close()
}