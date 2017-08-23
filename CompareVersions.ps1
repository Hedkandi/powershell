$cmdExe = 'C:\windows\system32\cmd.exe'

$Version = [System.Version]::new("0.1.0.0")
$cmdVersion = [System.Version]::new(([System.Diagnostics.FileVersionInfo]::GetVersionInfo($cmdExe).ProductVersion))

Write-Host "Version: $Version`ncmdVersion: $cmdVersion"

($cmdVersion -lt $Version)
