<#
.SYNOPSIS
    QuickSetup - GUI app picker that installs selected apps via winget.

.DESCRIPTION
    Sleek dark-themed checkbox list grouped by category. Nothing is selected by
    default - you choose exactly what gets installed. Click Install and watch a
    progress bar + live log as it works through your picks.

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

# ---- App list grouped by category: Name, winget Id ----
# Nothing is checked by default. Find more IDs by running: winget search <name>
$Categories = [ordered]@{
    "Browsers" = @(
        @{ Name = "Google Chrome"; Id = "Google.Chrome" }
        @{ Name = "Mozilla Firefox"; Id = "Mozilla.Firefox" }
        @{ Name = "Yandex Browser"; Id = "Yandex.Browser" }
        @{ Name = "Pale Moon"; Id = "MoonchildProductions.PaleMoon" }
        @{ Name = "Waterfox"; Id = "Waterfox.Waterfox" }
    )
    "Media" = @(
        @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC" }
        @{ Name = "Spotify"; Id = "Spotify.Spotify" }
        @{ Name = "YouTube Music Desktop"; Id = "Ytmdesktop.Ytmdesktop" }
        @{ Name = "Kodi"; Id = "XBMCFoundation.Kodi" }
        @{ Name = "Harmonoid"; Id = "Harmonoid.Harmonoid" }
        @{ Name = "Harmony"; Id = "VincentL.Harmony" }
        @{ Name = "yt-dlp"; Id = "yt-dlp.yt-dlp" }
    )
    "Communication" = @(
        @{ Name = "Zoom"; Id = "Zoom.Zoom" }
        @{ Name = "Discord"; Id = "Discord.Discord" }
        @{ Name = "LocalSend"; Id = "LocalSend.LocalSend" }
    )
    "Utilities" = @(
        @{ Name = "7-Zip"; Id = "7zip.7zip" }
        @{ Name = "WinRAR"; Id = "RARLab.WinRAR" }
        @{ Name = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit" }
        @{ Name = "Notepad++"; Id = "Notepad++.Notepad++" }
        @{ Name = "Microsoft PowerToys"; Id = "Microsoft.PowerToys" }
        @{ Name = "Xournal++"; Id = "Xournal++.Xournal++" }
        @{ Name = "Obsidian"; Id = "Obsidian.Obsidian" }
    )
    "Dev Tools & Networking" = @(
        @{ Name = "Git"; Id = "Git.Git" }
        @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" }
        @{ Name = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS" }
        @{ Name = "Python 3"; Id = "Python.Python.3.12" }
        @{ Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal" }
        @{ Name = "Docker Desktop"; Id = "Docker.DockerDesktop" }
        @{ Name = "Postman"; Id = "Postman.Postman" }
        @{ Name = "Wireshark"; Id = "WiresharkFoundation.Wireshark" }
    )
    "Streaming & Creative" = @(
        @{ Name = "OBS Studio"; Id = "OBSProject.OBSStudio" }
        @{ Name = "Streamlabs OBS"; Id = "Streamlabs.StreamlabsOBS" }
    )
}

# ---- Build the grouped checkbox XAML dynamically (nothing checked) ----
$groupXaml = ""
foreach ($category in $Categories.Keys) {
    $upperCat = $category.ToUpper().Replace("&", "&amp;")
    $groupXaml += "<TextBlock Text=`"$upperCat`" Style=`"{StaticResource CategoryHeader}`"/>`n"
    foreach ($app in $Categories[$category]) {
        $safeName = $app.Name.Replace("&", "&amp;")
        $groupXaml += "<CheckBox Content=`"$safeName`" Tag=`"$($app.Id)`" IsChecked=`"False`"/>`n"
    }
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinSpark" Height="700" Width="460"
        WindowStartupLocation="CenterScreen"
        Background="#0F0F17"
        FontFamily="Segoe UI">
    <Window.Resources>

        <SolidColorBrush x:Key="AccentBrush" Color="#6366F1"/>
        <SolidColorBrush x:Key="AccentHoverBrush" Color="#7C7FF5"/>
        <SolidColorBrush x:Key="SurfaceBrush" Color="#1A1A26"/>
        <SolidColorBrush x:Key="SurfaceAltBrush" Color="#22222F"/>
        <SolidColorBrush x:Key="BorderBrush2" Color="#33334A"/>
        <SolidColorBrush x:Key="TextBrush" Color="#E8E8EF"/>
        <SolidColorBrush x:Key="MutedTextBrush" Color="#8B8CA8"/>

        <Style x:Key="CategoryHeader" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource MutedTextBrush}"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Margin" Value="2,18,0,6"/>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="{StaticResource TextBrush}"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Margin" Value="2,3,4,3"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <Border Background="Transparent" Padding="4">
                            <StackPanel Orientation="Horizontal">
                                <Border x:Name="Box" Width="18" Height="18" CornerRadius="5"
                                        Background="{StaticResource SurfaceAltBrush}"
                                        BorderBrush="{StaticResource BorderBrush2}" BorderThickness="1.3"
                                        VerticalAlignment="Center">
                                    <Path x:Name="CheckMark" Data="M2,7 L6.5,11.5 L14,2"
                                          Stroke="White" StrokeThickness="2"
                                          StrokeStartLineCap="Round" StrokeEndLineCap="Round"
                                          StrokeLineJoin="Round" Visibility="Collapsed"/>
                                </Border>
                                <ContentPresenter Margin="10,0,0,0" VerticalAlignment="Center"/>
                            </StackPanel>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="Box" Property="Background" Value="{StaticResource AccentBrush}"/>
                                <Setter TargetName="Box" Property="BorderBrush" Value="{StaticResource AccentBrush}"/>
                                <Setter TargetName="CheckMark" Property="Visibility" Value="Visible"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Box" Property="BorderBrush" Value="{StaticResource AccentBrush}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource SurfaceAltBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource TextBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush2}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="7">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="#2C2C3D"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="AccentButton" TargetType="Button" BasedOn="{StaticResource ModernButton}">
            <Setter Property="Background" Value="{StaticResource AccentBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource AccentBrush}"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{TemplateBinding Background}" CornerRadius="7">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource AccentHoverBrush}"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ProgressBar">
            <Setter Property="Background" Value="{StaticResource SurfaceAltBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource AccentBrush}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Height" Value="10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Border Background="{TemplateBinding Background}" CornerRadius="5">
                            <Grid ClipToBounds="True">
                                <Border x:Name="PART_Track"/>
                                <Border x:Name="PART_Indicator" Background="{TemplateBinding Foreground}"
                                        CornerRadius="5" HorizontalAlignment="Left"/>
                            </Grid>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#0B0B12"/>
            <Setter Property="Foreground" Value="#B4B6D9"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrush2}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="11"/>
        </Style>

    </Window.Resources>

    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="150"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,10">
            <TextBlock Text="WinSpark" FontSize="22" FontWeight="Bold" Foreground="{StaticResource TextBrush}"/>
            <TextBlock Text="Pick what you want installed. Nothing runs until you say so." FontSize="12" Foreground="{StaticResource MutedTextBrush}" Margin="0,2,0,0"/>
        </StackPanel>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="CheckboxPanel">
                $groupXaml
            </StackPanel>
        </ScrollViewer>

        <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,14,0,10">
            <Button x:Name="SelectAllBtn" Content="Select All" Width="100" Margin="0,0,8,0" Style="{StaticResource ModernButton}"/>
            <Button x:Name="SelectNoneBtn" Content="Select None" Width="100" Margin="0,0,8,0" Style="{StaticResource ModernButton}"/>
            <Button x:Name="InstallBtn" Content="Install Selected" Width="150" Style="{StaticResource AccentButton}"/>
        </StackPanel>

        <Grid Grid.Row="3" Margin="0,0,0,10">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <ProgressBar x:Name="ProgressBar" Grid.Row="0" Minimum="0" Maximum="100" Value="0"/>
            <TextBlock x:Name="ProgressLabel" Grid.Row="1" Text="" FontSize="11" Foreground="{StaticResource MutedTextBrush}" Margin="0,6,0,0" HorizontalAlignment="Center"/>
        </Grid>

        <TextBox x:Name="LogBox" Grid.Row="4" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
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
        "WinSpark",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$window.ShowDialog() | Out-Null
