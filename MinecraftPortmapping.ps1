param (
    $PortMapperPath
)

Write-Host -ForegroundColor Blue "Starting the simple way of playing minecraft with your friends."
Write-Host -ForegroundColor Yellow "This script requires an internetgateway which has support for upnp."

function Get-PortMapperJarPath {
    Write-Host "Ask user to locate portmapper-jar"
    $PortMapperJarPathDialog = [System.Windows.Forms.OpenFileDialog]::new()
    $PortMapperJarPathDialog.Filter = "portmapper 2.1.1 |portmapper-2.1.1.jar"
    $PortMapperJarPathDialog.InitialDirectory = "$($env:USERPROFILE)\Downloads"
    $PortMapperJarPathDialog.ShowDialog() | Out-Null
    Write-Host "User selected jar-file!"
    $PortMapperJarPathDialog.FileName
}

function Get-MinecraftLauncherPath {
    Write-Host "Retrieving Minecraft Launcher path from registry"
    Get-ItemPropertyValue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Mojang\InstalledProducts\Minecraft Launcher" -Name 'InstallLocation'
}

$MappingName = 'MinecraftServer'
$LastGamePort = 0
$LauncherLogPath = "$($env:APPDATA)\.minecraft\launcher_log.txt"
$PortMapperJarPath = "$($env:USERPROFILE)\Downloads\portmapper-2.1.1.jar"

if ([string]::IsNullOrEmpty($PortMapperPath)) {
    try {
        $PortMapperJarPath = Get-PortMapperJarPath
    } catch {
        Write-Host $_.Message
        $PortMapperJarPath = $PortMapperPath
    }
}

if ($null -eq $PortMapperJarPath -or (-not (Test-Path -Path $PortMapperJarPath))) {
    throw "Missing PortMapperJarPath!"
}

$MinecraftLauncherPath = Get-MinecraftLauncherPath
if ((Test-Path -Path $MinecraftLauncherPath)) {
    $MinecraftJavaPath = Join-Path -Path (Get-MinecraftLauncherPath) -ChildPath "runtime\jre-x64\bin"
}
else {
    throw "Missing Minecraft Launcher!"
}

function Test-PortMapped {
    Param (
        $Port
    )
    $PortmapperOutputPath = "$($env:TEMP)\portmapper_list.txt"
    $proc = Start-Process -PassThru -FilePath "$MinecraftJavaPath\java.exe" -ArgumentList "-jar `"$PortMapperJarPath`" -list" -NoNewWindow -Wait -RedirectStandardOutput $PortmapperOutputPath
    if ($proc.ExitCode -eq 0) {
        Get-Content -Path $PortmapperOutputPath | Select-String -Pattern '(TCP|UDP) :([0-9]+) -> ([0-9\.]+):([0-9]+) enabled ([a-zA-Z0-9]+)' | ForEach-Object {
            $MappedProtocol = $_.Matches.Groups[1].Value
            $MappedExternalPort = $_.Matches.Groups[2].Value
            $MappedInternalIP = $_.Matches.Groups[3].Value
            $MappedInternalPort = $_.Matches.Groups[4].Value
            $MappedName = $_.Matches.Groups[5].Value
            #Write-Host $MappedExternalPort
            if ($MappedExternalPort -eq $Port) {
                Write-Host -ForegroundColor Yellow "The current port that minecraft is using is already mapped using upnp: "
                Write-Host -ForegroundColor Yellow "$MappedProtocol :$MappedExternalPort -> $($MappedInternalIP):$MappedInternalPort with name '$MappedName'"
                return $true
            }
        }
    }
    return $false
}


if (-not (Test-path -Path $MinecraftJavaPath)) {
    throw "Minecraft Launcher is not installed!"
}

if ((Test-path -Path $LauncherLogPath)) {
    $Pattern = 'Info\: ([0-9\-]+ [0-9:\-\.]+)\: .* Info Started serving on ([0-9]+)'
    $GameInfo = Get-Content -Path $LauncherLogPath -Raw | Select-String -Pattern $Pattern | ForEach-Object { $_.Matches }
    $LastGamePort = $GameInfo.Groups[2].Value
    $LastGameOpenTime = $GameInfo.Groups[1].Value

    if ($LastGamePort -gt 0) {
        Write-Host -NoNewline "Found the last used port ("
        Write-Host -NoNewline -ForegroundColor Green $LastGamePort
        Write-Host -NoNewline ") which was opened at "
        Write-Host -NoNewline -ForegroundColor Green $LastGameOpenTime
        Write-Host "."
    }
}
else {
    throw "Missing launcher_log.txt, do you have a Minecraft game running? I think not."
}

if ((Test-path -Path $PortMapperJarPath)) {
    if (-not (Test-PortMapped -Port $LastGamePort)) {
        Write-Host "Port ($LastGamePort) has not been mapped. Will try to map it now!"
        $proc = Start-Process -PassThru -FilePath "$MinecraftJavaPath\java.exe" -ArgumentList "-jar `"$PortMapperJarPath`" -protocol TCP -lib `"org.chris.portmapper.router.weupnp.WeUPnPRouterFactory`" -add -externalPort $LastGamePort -internalPort $LastGamePort -description `"$MappingName`"" -NoNewWindow -Wait
        if ($proc.ExitCode -eq 0) {
            Write-Host "Looks like portmapping was done, need to verify!"
            if ((Test-PortMapped -Port $LastGamePort)) {
                Write-Host -ForegroundColor Green "Port ($LastGamePort) has been mapped to this computer!"
                Write-Host -ForegroundColor Green "Players connecting to this server should connect to $($ExternalIP):$LastGamePort"
            }
        }
    }
}
else {
    throw "Missing portmapper!"
}

Read-Host -Prompt "Press enter to close this script!"
