function Get-MsiProperty {
    param(
        [string]$MsiDatabasePath,
        [string]$sProperty
    )
    Add-Type -Path "C:\Program Files (x86)\WiX Toolset v4.0\bin\WixToolset.Dtf.WindowsInstaller.dll";
    # Ref: http://www.laurierhodes.info/?q=node/104

    Write-Information "Opening '$MsiDatabasePath'"
    if ($MsiDatabasePath) {
        try {
            $oDatabase = New-Object WixToolset.Dtf.WindowsInstaller.Database($MsiDatabasePath);
        } catch {}
        if ($oDatabase) {
            $sSQLQuery = "SELECT * FROM Property WHERE Property = '$sProperty'"
            [WixToolset.Dtf.WindowsInstaller.View]$oView = $oDatabase.OpenView($sSQLQuery)
            $oView.Execute()

            while ($oRecord = $oView.Fetch()) {
                if ($oRecord.GetString(1) -eq "$sProperty") {
                    return $oRecord.GetString(2)
                }
            }
            $oView.Close()
            $oDatabase.Dispose()
        }
        else {
            throw "Failed to open database."
        }
    }
}
