function Global:Invoke-SCCMSchedule {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:ComputerName,
        [parameter(mandatory=$true)]
        [ValidateSet("Hardware Inventory","Software Inventory","Discovery Inventory","File Collection","IDMIF Collection","Client Machine Authentication ","Request Machine Assignments","Evaluate Machine Policies","Refresh Default MP Task","LS (Location Service) Refresh Locations Task","LS (Location Service) Timeout Refresh Task","Policy Agent Request Assignment (User)","Policy Agent Evaluate Assignment (User)","Software Metering Generating Usage Report","Source Update Message","Clearing proxy settings cache","Machine Policy Agent Cleanup","User Policy Agent Cleanup","Policy Agent Validate Machine Policy / Assignment","Policy Agent Validate User Policy / Assignment","Retrying/Refreshing certificates in AD on MP","Peer DP Status reporting","Peer DP Pending package check schedule","SUM Updates install schedule","NAP action","Hardware Inventory Collection Cycle","Software Inventory Collection Cycle","Discovery Data Collection Cycle","File Collection Cycle","IDMIF Collection Cycle","Software Metering Usage Report Cycle","Windows Installer Source List Update Cycle","Software Updates Assignments Evaluation Cycle","Branch Distribution Point Maintenance Task","DCM policy","Send Unsent State Message","State System policy cache cleanout","Scan by Update Source","Update Store Policy","State system policy bulk send high","State system policy bulk send low","AMT Status Check Policy","Application manager policy action","Application manager user policy action","Application manager global evaluation action","Power management start summarizer","Endpoint deployment reevaluate","Endpoint AM policy reevaluate","External event detection")]
        [string[]]$SCCMSchedule
    )

    begin {
        $ScheduleList = @{
        "Hardware Inventory" = "{00000000-0000-0000-0000-000000000001}";
        "Software Inventory" = "{00000000-0000-0000-0000-000000000002}";
        "Discovery Inventory" = "{00000000-0000-0000-0000-000000000003}";
        "File Collection" = "{00000000-0000-0000-0000-000000000010}";
        "IDMIF Collection" = "{00000000-0000-0000-0000-000000000011}";
        "Client Machine Authentication " = "{00000000-0000-0000-0000-000000000012}";
        "Request Machine Assignments" = "{00000000-0000-0000-0000-000000000021}";
        "Evaluate Machine Policies" = "{00000000-0000-0000-0000-000000000022}";
        "Refresh Default MP Task" = "{00000000-0000-0000-0000-000000000023}";
        "LS (Location Service) Refresh Locations Task" = "{00000000-0000-0000-0000-000000000024}";
        "LS (Location Service) Timeout Refresh Task" = "{00000000-0000-0000-0000-000000000025}";
        "Policy Agent Request Assignment (User)" = "{00000000-0000-0000-0000-000000000026}";
        "Policy Agent Evaluate Assignment (User)" = "{00000000-0000-0000-0000-000000000027}";
        "Software Metering Generating Usage Report" = "{00000000-0000-0000-0000-000000000031}";
        "Source Update Message" = "{00000000-0000-0000-0000-000000000032}";
        "Clearing proxy settings cache" = "{00000000-0000-0000-0000-000000000037}";
        "Machine Policy Agent Cleanup" = "{00000000-0000-0000-0000-000000000040}";
        "User Policy Agent Cleanup" = "{00000000-0000-0000-0000-000000000041}";
        "Policy Agent Validate Machine Policy / Assignment" = "{00000000-0000-0000-0000-000000000042}";
        "Policy Agent Validate User Policy / Assignment" = "{00000000-0000-0000-0000-000000000043}";
        "Retrying/Refreshing certificates in AD on MP" = "{00000000-0000-0000-0000-000000000051}";
        "Peer DP Status reporting" = "{00000000-0000-0000-0000-000000000061}";
        "Peer DP Pending package check schedule" = "{00000000-0000-0000-0000-000000000062}";
        "SUM Updates install schedule" = "{00000000-0000-0000-0000-000000000063}";
        "NAP action" = "{00000000-0000-0000-0000-000000000071}";
        "Hardware Inventory Collection Cycle" = "{00000000-0000-0000-0000-000000000101}";
        "Software Inventory Collection Cycle" = "{00000000-0000-0000-0000-000000000102}";
        "Discovery Data Collection Cycle" = "{00000000-0000-0000-0000-000000000103}";
        "File Collection Cycle" = "{00000000-0000-0000-0000-000000000104}";
        "IDMIF Collection Cycle" = "{00000000-0000-0000-0000-000000000105}";
        "Software Metering Usage Report Cycle" = "{00000000-0000-0000-0000-000000000106}";
        "Windows Installer Source List Update Cycle" = "{00000000-0000-0000-0000-000000000107}";
        "Software Updates Assignments Evaluation Cycle" = "{00000000-0000-0000-0000-000000000108}";
        "Branch Distribution Point Maintenance Task" = "{00000000-0000-0000-0000-000000000109}";
        "DCM policy" = "{00000000-0000-0000-0000-000000000110}";
        "Send Unsent State Message" = "{00000000-0000-0000-0000-000000000111}";
        "State System policy cache cleanout" = "{00000000-0000-0000-0000-000000000112}";
        "Scan by Update Source" = "{00000000-0000-0000-0000-000000000113}";
        "Update Store Policy" = "{00000000-0000-0000-0000-000000000114}";
        "State system policy bulk send high" = "{00000000-0000-0000-0000-000000000115}";
        "State system policy bulk send low" = "{00000000-0000-0000-0000-000000000116}";
        "AMT Status Check Policy" = "{00000000-0000-0000-0000-000000000120}";
        "Application manager policy action" = "{00000000-0000-0000-0000-000000000121}";
        "Application manager user policy action" = "{00000000-0000-0000-0000-000000000122}";
        "Application manager global evaluation action" = "{00000000-0000-0000-0000-000000000123}";
        "Power management start summarizer" = "{00000000-0000-0000-0000-000000000131}";
        "Endpoint deployment reevaluate" = "{00000000-0000-0000-0000-000000000221}";
        "Endpoint AM policy reevaluate" = "{00000000-0000-0000-0000-000000000222}";
        "External event detection" = "{00000000-0000-0000-0000-000000000223}";

        }
        
        if (-not (Test-Connection -Count 1 -ComputerName $ComputerName -ErrorAction Stop)) {
            Write-Error "Unable to connect to target computer '$ComputerName'"
        }

        $WMIParams = @{}
        $WMIParams.Add('ComputerName',$ComputerName)
        $WMIParams.Add('Class','SMS_Client')
        $WMIParams.Add('Namespace','root\ccm')
        $WMIParams.Add('Name','TriggerSchedule')
        $WMIParams.Add('EnableAllPrivileges',$true)
        $WMIParams.Add('ErrorAction','Stop')
        $WMIParams.Add('ArgumentList','')
    }
    process {
        foreach ($Schedule in $SCCMSchedule) {
            try {
                $WMIParams.ArgumentList = $ScheduleList.$Schedule
                Write-Debug "$($WMIParams.ArgumentList) @ '$ComputerName'"
                if ([int](Invoke-WmiMethod @WMIParams).ReturnValue -ne 0) {
                    Write-Error "ReturnValue was not 0."
                }
            } catch { Write-Host "Failed to run '$Schedule' with message '$_'" }
        }
    }
}
