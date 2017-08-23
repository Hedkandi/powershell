function Global:New-InputBox {
    param(
        [switch]$PasswordBox,
        [string]$WindowTitle,
        [string]$Title,
        [string]$Content
    )
    begin {
    $windowDef = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" WindowStartupLocation="CenterScreen" WindowStyle="ToolWindow" ResizeMode="NoResize" SizeToContent="WidthAndHeight" Topmost="True" ShowInTaskbar="False">
    <Grid Margin="5,5,5,5" x:Name="controlGrid">
        <Button x:Name="bOK" Content="OK" HorizontalAlignment="Right" VerticalAlignment="Bottom" Width="75" Height="23"/>
        <Label x:Name="lTitle" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Height="25" Width="265"/>
    </Grid>
</Window>
"@
        $SaveInputAndClose = {
            param(
                $evt,
                $Input
            )
            $Script:UserInput = $Input
            $evt.Handled = $true
            $Window.Window.Close()
        }
    }
    process {
        $Window = Get-XamlWindow -WindowXMLString $windowDef
        
        # If this input is of password type, use passwordbox instead of textbox
        if ($PasswordBox) {
            [void]($tbInput = [System.Windows.Controls.PasswordBox]::new())
        }
        else {
            [void]($tbInput = [System.Windows.Controls.TextBox]::new())
            $tbInput.Text = $Content
        }
        # Position and set properties of the new component
        $tbInput.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
        $tbInput.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
        [void]($tbInputMargin = New-Object System.Windows.Thickness)
        $tbInputMargin.Top = 35
        $tbInput.Margin = $tbInputMargin
        $tbInput.Height = 23
        $tbInput.Width = 185
        $tbInput.Name = "tbInput"
        $tbInput.TabIndex = 1
        # If Enter is pressed in the inputbox we should save the input and exit.
        $tbInput.Add_KeyUp({
            if ($_.Key -eq [System.Windows.Input.Key]::Enter) {
                $SaveInputAndClose.Invoke($_,$tbInput.Text)
            }
        })
        
        # Add the component to the form
        [void]$Window.Elements.controlGrid.AddChild($tbInput)
        
        # Add an eventhandler for Click on the OK-button
        ($Window.Elements.bOK).Add_Click({
            $SaveInputAndClose.Invoke($_,$tbInput.Text)
        })

        # Add an eventhandler for escape on the form
        $Window.Window.Add_KeyUp({
            if ($_.Key -eq [System.Windows.Input.Key]::Escape) {
                $SaveInputAndClose.Invoke($_)
            }
        })
        
        # Set the text for the label and the windows title
        ($Window.Elements.lTitle).Content = $Title
        $Window.Window.Title = $WindowTitle
        
        # Make sure the window is activated and is ready for input
        $Window.Window.Add_Loaded({
            Start-Sleep -Milliseconds 300
            [void]$tbInput.Focus()
            [void]$Window.Window.Activate()
        })
        
        
        [void]$Window.Window.ShowDialog()
        
        return $Script:UserInput
    }
}
