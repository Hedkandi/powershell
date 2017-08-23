function Global:Get-XAMLWindow {
    param(
        [string]$WindowXMLString
    )
    begin {
        $form = $null
        $reader = $null
        
        # Add required DLL's
        Add-Type -AssemblyName PresentationFramework
        ###
        # The following line was found at https://foxdeploy.com/functions/ise-snippets/xaml-to-gui/
        ###
        [xml]$WindowXML = $WindowXMLString -replace 'mc:Ignorable="d"','' -replace "x:N",'N' #-replace '^<Win.*', '<Window'
    }
    process {
        ###
        # XAML example found at https://blogs.technet.microsoft.com/platformspfe/2014/01/20/integrating-xaml-into-powershell/
        ###
        
        # Initialize variables
        $reader=(New-Object System.Xml.XmlNodeReader ($WindowXML))
        # Create the form from xaml
        try{
            $Form=[Windows.Markup.XamlReader]::Load($reader)
        }
        catch{
            $_
            Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered.";
            break
        }

        $Elements = New-Object PSObject
        $ElementNameMatches = ([Regex]::Matches($WindowXMLString,"Name=`"([a-z0-9A-Z]+)`"[ >]"))
        $ElementNameMatches | Foreach-Object {
            $Elements | Add-Member $_.Groups[1] $Form.FindName($_.Groups[1])
        }
        
        return @{
            Window = $Form;
            Elements = $Elements;
        }
    }
}
