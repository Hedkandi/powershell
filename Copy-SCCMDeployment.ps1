function Copy-SCCMDeployment {
    [CmdletBinding(SupportsShouldProcess=$true, 
                  HelpUri = 'http://www.microsoft.com/')]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $OldApplication,
        [ValidateNotNullOrEmpty()]
        [string]
        $NewApplication,
        [switch]
        $Remove
    )
        Begin
    {
        if ((Get-Location).Drive.Provider.Name -ne "CMSite") {
            throw "Wrong location."
        }

        $DeploymentIntent = @()
        $DeploymentIntent += ""
        $DeploymentIntent += "Required"
        $DeploymentIntent += "Available"

        $DesiredConfigType = @()
        $DesiredConfigType += ""
        $DesiredConfigType += "Install"
        $DesiredConfigType += "Uninstall"

        Write-Host "Deployments of '$OldApplication' will be copied to '$NewApplication'"
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
            $OldDeployments = Get-CMDeployment -SoftwareName $OldApplication
            if ($OldDeployments.Count -gt 0) {
                $OldDeployments | % {
                    $CurrentDeployment = $_
                    $NewDeploy = $null
                    try {
                        Write-Information "Deploying '$NewApplication' to '$($CurrentDeployment.CollectionName)'"
                        $NewDeploy = Start-CMApplicationDeployment -Name $NewApplication -CollectionName "$($CurrentDeployment.CollectionName)" -DeployAction "$($DesiredConfigType[$CurrentDeployment.DesiredConfigType])" -DeployPurpose "$($DeploymentIntent[$CurrentDeployment.DeploymentIntent])" -UserNotification DisplaySoftwareCenterOnly -PassThru -ErrorAction SilentlyContinue
                    } catch {
                        if ((Get-CMDeployment -SoftwareName $NewApplication -CollectionName $CurrentDeployment.CollectionName)) {
                            Write-Information "'$NewApplication' is already deployed to '$($CurrentDeployment.CollectionName)'"
                            if ($Remove.IsPresent) {
                                Write-Information "Removing '$($OldApplication)' from $($CurrentDeployment.CollectionName)"
                                Remove-CMDeployment -DeploymentId $CurrentDeployment.DeploymentID -ApplicationName $OldApplication -Force
                            }
                        }
                    }
                    if ($NewDeploy -and $Remove.IsPresent) {
                        Write-Information "Removing '$($OldApplication)' from $($CurrentDeployment.CollectionName)"
                        Remove-CMDeployment -DeploymentId $CurrentDeployment.DeploymentID -ApplicationName $OldApplication -Force
                    }
                }
            }
            else {
                Write-Host "Old application '$OldApplication' does not have any deployments."
            }
        }
    }
    End
    {
    }
}
