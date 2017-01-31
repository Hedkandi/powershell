function Get-MsiProperty {
    param(
        [string]$Path,
        [string]$Property
    )
    Write-Information "Opening '$Path'"
    if ($Path) {
        try {
            $oDatabase = New-Object WixToolset.Dtf.WindowsInstaller.Database($Path);
        } catch {}
        if ($oDatabase) {
            $sSQLQuery = "SELECT * FROM Property WHERE Property = '$Property'"
            [WixToolset.Dtf.WindowsInstaller.View]$oView = $oDatabase.OpenView($sSQLQuery)
            $oView.Execute()

            while ($oRecord = $oView.Fetch()) {
                if ($oRecord.GetString(1) -eq "$Property") {
                    return $oRecord.GetString(2)
                }
            }
            $oView.Close()
            $oDatabase.Close()
            $oDatabase.Dispose()
        }
        else {
            throw "Failed to open database."
        }
    }
}
