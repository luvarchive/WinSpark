<#
.SYNOPSIS
    GUI app picker that installs selected apps via winget, grouped by category with a progress bar.

.DESCRIPTION
    Shows apps grouped under category headers (Browsers, Media, Utilities, etc.) with checkboxes.
    Tick what you want, click Install, and watch a progress bar + live log as it installs.

.NOTES
    - Run as Administrator for a smooth, silent install experience.
    - Requires winget (built into Windows 10/11 via "App Installer").
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# ---- Check winget is available ----
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    [System.Windows.Forms.MessageBox]::Show(
        "winget was not found on this system.`n`nInstall 'App Installer' from the Microsoft Store, then re-run this script.",
        "winget Missing",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

# ---- App list grouped by category: Name, winget Id, default-checked ----
# Find more IDs by running: winget search <name>
$Categories = [ordered]@{
    "Browsers" = @(
        @{ Name = "Google Chrome";   Id = "Google.Chrome";   Checked = $true  }
        @{ Name = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Checked = $false }
    )
    "Media" = @(
        @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC";     Checked = $true  }
        @{ Name = "Spotify";          Id = "Spotify.Spotify";  Checked = $false }
    )
    "Communication" = @(
        @{ Name = "Zoom";    Id = "Zoom.Zoom";       Checked = $false }
        @{ Name = "Discord"; Id = "Discord.Discord"; Checked = $false }
    )
    "Utilities" = @(
        @{ Name = "7-Zip";                Id = "7zip.7zip";                   Checked = $true  }
        @{ Name = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit"; Checked = $false }
        @{ Name = "Notepad++";            Id = "Notepad++.Notepad++";         Checked = $true  }
        @{ Name = "Microsoft PowerToys";  Id = "Microsoft.PowerToys";         Checked = $false }
    )
    "Dev Tools" = @(
        @{ Name = "Git";                  Id = "Git.Git";                     Checked = $false }
        @{ Name = "Visual Studio Code";   Id = "Microsoft.VisualStudioCode";  Checked = $false }
        @{ Name = "Node.js LTS";          Id = "OpenJS.NodeJS.LTS";           Checked = $false }
        @{ Name = "Python 3";             Id = "Python.Python.3.12";          Checked = $false }
        @{ Name = "Windows Terminal";     Id = "Microsoft.WindowsTerminal";   Checked = $false }
        @{ Name = "Docker Desktop";       Id = "Docker.DockerDesktop";        Checked = $false }
        @{ Name = "Postman";              Id = "Postman.Postman";             Checked = $false }
    )
}

# ---- Build the grouped checkbox XAML dynamically ----
$groupXaml = ""
foreach ($category in $Categories.Keys) {
    $groupXaml += "<TextBlock Text=`"$category`" FontWeight=`"Bold`" FontSize=`"14`" Margin=`"2,10,0,4`" Foreground=`"#0078D4`"/>`n"
    foreach ($app in $Categories[$category]) {
        $isChecked = if ($app.Checked) { "True" } else { "False" }
        $groupXaml += "<CheckBox Content=`"$($app.Name)`" Tag=`"$($app.Id)`" IsChecked=`"$isChecked`" Margin=`"16,2,4,2`" FontSize=`"13`"/>`n"
    }
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="App Installer" Height="640" Width="440"
        WindowStartupLocation="CenterScreen">
    <Grid Margin="12">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="150"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="Select apps to install:" FontSize="16" FontWeight="Bold" Margin="0,0,0,4"/>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="CheckboxPanel">
                $groupXaml
            </StackPanel>
        </ScrollViewer>

        <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,10,0,8">
            <Button x:Name="SelectAllBtn" Content="Select All" Width="90" Margin="0,0,6,0"/>
            <Button x:Name="SelectNoneBtn" Content="Select None" Width="90" Margin="0,0,6,0"/>
            <Button x:Name="InstallBtn" Content="Install Selected" Width="140" Background="#0078D4" Foreground="White" FontWeight="Bold"/>
        </StackPanel>

        <Grid Grid.Row="3" Margin="0,0,0,8">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <ProgressBar x:Name="ProgressBar" Grid.Row="0" Height="18" Minimum="0" Maximum="100" Value="0"/>
            <TextBlock x:Name="ProgressLabel" Grid.Row="1" Text="" FontSize="11" Margin="0,3,0,0" HorizontalAlignment="Center"/>
        </Grid>

        <TextBox x:Name="LogBox" Grid.Row="4" IsReadOnly="True" VerticalScrollBarVisibility="Auto"
                  TextWrapping="Wrap" FontFamily="Consolas" FontSize="11" Background="#1e1e1e" Foreground="#d4d4d4"/>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$checkboxPanel  = $window.FindName("CheckboxPanel")
$selectAllBtn   = $window.FindName("SelectAllBtn")
$selectNoneBtn  = $window.FindName("SelectNoneBtn")
$installBtn     = $window.FindName("InstallBtn")
$logBox         = $window.FindName("LogBox")
$progressBar    = $window.FindName("ProgressBar")
$progressLabel  = $window.FindName("ProgressLabel")

function Write-GuiLog {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logBox.AppendText("[$timestamp] $Message`r`n")
    $logBox.ScrollToEnd()
    [System.Windows.Forms.Application]::DoEvents()
}

# Only real CheckBox elements (skip the TextBlock category headers)
function Get-CheckBoxes {
    $checkboxPanel.Children | Where-Object { $_ -is [System.Windows.Controls.CheckBox] }
}

$selectAllBtn.Add_Click({
    foreach ($cb in (Get-CheckBoxes)) { $cb.IsChecked = $true }
})

$selectNoneBtn.Add_Click({
    foreach ($cb in (Get-CheckBoxes)) { $cb.IsChecked = $false }
})

$installBtn.Add_Click({
    $selected = Get-CheckBoxes | Where-Object { $_.IsChecked -eq $true }

    if ($selected.Count -eq 0) {
        Write-GuiLog "No apps selected."
        return
    }

    $installBtn.IsEnabled = $false
    $selectAllBtn.IsEnabled = $false
    $selectNoneBtn.IsEnabled = $false

    $total = $selected.Count
    $done = 0
    $succeeded = 0
    $failed = 0

    $progressBar.Value = 0
    $progressBar.Maximum = $total
    Write-GuiLog "Starting install of $total app(s)..."

    foreach ($cb in $selected) {
        $name = $cb.Content
        $id = $cb.Tag

        $progressLabel.Text = "Installing $name  ($($done + 1) of $total)"
        [System.Windows.Forms.Application]::DoEvents()

        Write-GuiLog "Installing $name..."

        $result = winget install --id $id --silent --accept-source-agreements --accept-package-agreements -e 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-GuiLog "  Done: $name"
            $succeeded++
        }
        elseif ($result -match "No newer package versions" -or $result -match "already installed") {
            Write-GuiLog "  Already installed: $name"
            $succeeded++
        }
        else {
            Write-GuiLog "  FAILED: $name (exit code $exitCode)"
            $failed++
        }

        $done++
        $progressBar.Value = $done
        [System.Windows.Forms.Application]::DoEvents()
    }

    $progressLabel.Text = "Complete: $succeeded succeeded, $failed failed"
    Write-GuiLog "---- Done. Succeeded: $succeeded, Failed: $failed ----"

    $installBtn.IsEnabled = $true
    $selectAllBtn.IsEnabled = $true
    $selectNoneBtn.IsEnabled = $true

    [System.Windows.Forms.MessageBox]::Show(
        "Install finished.`n`nSucceeded: $succeeded`nFailed: $failed",
        "App Installer",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$window.ShowDialog() | Out-Null
