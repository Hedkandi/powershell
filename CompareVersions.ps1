$OldVersion = [System.Version]::new("0.1.0.0")
$NewVersion = [System.Version]::new(([System.Diagnostics.FileVersionInfo]::GetVersionInfo("PATH").FileVersion))

Write-Host "NewVersion: $NewVersion"
Write-Host "OldVersion: $OldVersion"

($OldVersion -lt $NewVersion)
