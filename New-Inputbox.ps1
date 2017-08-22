function New-InputBox {
    param(
        [switch]$PasswordBox,
        [string]$WindowTitle,
        [string]$Title,
        [string]$Content
    )
 
$windowDef = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" SizeToContent="WidthAndHeight" Topmost="True" ShowInTaskbar="False">
    <Grid Margin="5,5,5,5" x:Name="controlGrid">
        <Button x:Name="bOK" Content="OK" HorizontalAlignment="Right" VerticalAlignment="Bottom" Width="75" Height="23"/>
        <Label x:Name="lTitle" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="25" Width="265"/>
    </Grid>
</Window>
"@
    # Start from scratch
    $form = $null
    $reader = $null
    $xamlData = $null
    $handleInput = {
        $evt = [System.Windows.RoutedEventArgs]$_
        $Script:UserInput = $tbInput.Text
        $evt.Handled = $true
        $Form.Close()
    }
 
    # Add required DLL's
    Add-Type -AssemblyName PresentationFramework
 
    # Initialize variables
    $Script:UserInput = ""

    # Create the form from xaml
    try{
        $reader=(New-Object System.Xml.XmlNodeReader ([xml]$windowDef))
        $Form=[Windows.Markup.XamlReader]::Load($reader)
    }
    catch{
        $_
        Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered.";
        return
    }
 
    # If this input is of password type, use passwordbox instead of textbox
    if ($PasswordBox.IsPresent) {
        $tbInput = [System.Windows.Controls.PasswordBox]::new()
    }
    else {
        $tbInput = [System.Windows.Controls.TextBox]::new()
        $tbInput.Text = $Content
    }
    # Position and set properties of the new component
    $tbInput.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $tbInput.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $tbInputMargin =New-Object System.Windows.Thickness
    $tbInputMargin.Top = 35
    $tbInput.Margin = $tbInputMargin
    $tbInput.Height = 23
    $tbInput.Width = 185
    $tbInput.Name = "tbInput"
    $tbInput.TabIndex = 1
    # If Enter is pressed in the inputbox we should save the input and exit.
    $tbInput.Add_KeyUp({
        if ($_.Key -eq [System.Windows.Input.Key]::Enter) {
            $handleInput.Invoke($tbInput.Text)
        }
    })
 
    # Add the component to the form
    $controlGrid = $Form.FindName("controlGrid")
    $controlGrid.AddChild($tbInput)
 
    # Add an eventhandler for Click on the OK-button
    ($Form.FindName("bOK")).Add_Click({
        $handleInput.Invoke($tbInput.Text)
    })
 
    # Add an eventhandler for escape on the form
    $Form.Add_KeyUp({
        if ($_.Key -eq [System.Windows.Input.Key]::Escape) {
            $handleInput.Invoke()
        }
    })
 
    # Set the text for the label and the windows title
    ($Form.FindName("lTitle")).Content = $Title
    $Form.Title = $WindowTitle
 
    # Make sure the window is activated and is ready for input
    $Form.Add_Loaded({
        $tbInput.Focus()
        $Form.Activate()
    })
 
    # Go Gadget Go!
    [void]$Form.ShowDialog()
 
    return $Script:UserInput
}
