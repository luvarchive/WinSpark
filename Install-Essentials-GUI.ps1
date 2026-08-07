<#
.SYNOPSIS
    WinSpark - GUI app picker that installs/uninstalls selected apps via winget.

.DESCRIPTION
    Sleek dark-themed checkbox list grouped by category. Nothing is selected by
    default - you choose exactly what gets installed. Click Install to install
    your picks, or Uninstall Selected to remove them, and watch a progress bar
    + live log as it works through your picks.

.NOTES
    - Run as Administrator for a smooth, silent install/uninstall experience.
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

# ---- App list grouped by category: Name, winget Id, Desc ----
# Nothing is checked by default. Find more IDs by running: winget search <name>
$Categories = [ordered]@{
    "Browsers" = @(
        @{ Name = "Google Chrome"; Id = "Google.Chrome"; Desc = "Fast, widely-used browser with deep Google integration" }
        @{ Name = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Desc = "Open-source browser focused on privacy and customization" }
        @{ Name = "Yandex Browser"; Id = "Yandex.Browser"; Desc = "Chromium-based browser with built-in translation and security tools" }
        @{ Name = "Pale Moon"; Id = "MoonchildProductions.PaleMoon"; Desc = "Lightweight browser built for speed and efficiency" }
        @{ Name = "Waterfox"; Id = "Waterfox.Waterfox"; Desc = "Privacy-focused Firefox fork with legacy add-on support" }
        @{ Name = "Vivaldi"; Id = "VivaldiTechnologies.Vivaldi"; Desc = "Highly customizable browser with built-in tab management tools" }
        @{ Name = "Tor Browser"; Id = "TorProject.TorBrowser"; Desc = "Anonymized browsing through the Tor network" }
		
    )
    "Media" = @(
        @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Desc = "Plays virtually any audio or video format, no codecs needed" }
        @{ Name = "Spotify"; Id = "Spotify.Spotify"; Desc = "Music and podcast streaming service" }
        @{ Name = "YouTube Music Desktop"; Id = "Ytmdesktop.Ytmdesktop"; Desc = "Desktop app wrapper for YouTube Music" }
        @{ Name = "Kodi"; Id = "XBMCFoundation.Kodi"; Desc = "Media center for organizing and playing your movies, shows, and music" }
        @{ Name = "Harmonoid"; Id = "Harmonoid.Harmonoid"; Desc = "Music player and library manager" }
        @{ Name = "Harmony"; Id = "VincentL.Harmony"; Desc = "Lightweight utility app" }
        @{ Name = "yt-dlp"; Id = "yt-dlp.yt-dlp"; Desc = "Command-line tool for downloading video/audio from the web" }
        @{ Name = "IrfanView"; Id = "IrfanSkiljan.IrfanView"; Desc = "Fast, lightweight image viewer and editor" }
        @{ Name = "HandBrake"; Id = "HandBrake.HandBrake"; Desc = "Video transcoder for converting video between formats" }
        @{ Name = "foobar2000"; Id = "PeterPawlowski.foobar2000"; Desc = "Highly customizable, low-resource audio player" }
        @{ Name = "MusicBee"; Id = "MusicBee.MusicBee"; Desc = "Full-featured music manager and player" }
    )
    "Communication" = @(
        @{ Name = "Zoom"; Id = "Zoom.Zoom"; Desc = "Video conferencing and meetings" }
        @{ Name = "Discord"; Id = "Discord.Discord"; Desc = "Voice, video, and text chat for communities and friends" }
        @{ Name = "Telegram"; Id = "Telegram.TelegramDesktop"; Desc = "Cloud-based messaging with speed and security focus" }
        @{ Name = "WhatsApp"; Id = "WhatsApp.WhatsApp"; Desc = "Desktop client for WhatsApp messaging" }
        @{ Name = "Slack"; Id = "SlackTechnologies.Slack"; Desc = "Team messaging and collaboration platform" }
        @{ Name = "Microsoft Teams"; Id = "Microsoft.Teams"; Desc = "Chat, video calls, and collaboration for teams" }
        @{ Name = "Skype"; Id = "Microsoft.Skype"; Desc = "Video and voice calling app" }
        @{ Name = "Signal"; Id = "OpenWhisperSystems.Signal"; Desc = "Privacy-focused, end-to-end encrypted messaging" }
        @{ Name = "LocalSend"; Id = "LocalSend.LocalSend"; Desc = "Share files locally between devices, no internet required" }
    )
    "Utilities" = @(
        @{ Name = "7-Zip"; Id = "7zip.7zip"; Desc = "Free file archiver supporting most compression formats" }
        @{ Name = "WinRAR"; Id = "RARLab.WinRAR"; Desc = "Popular file archiver and compressor" }
        @{ Name = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit"; Desc = "View, print, and annotate PDF files" }
        @{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Desc = "Lightweight source code and text editor" }
        @{ Name = "Microsoft PowerToys"; Id = "Microsoft.PowerToys"; Desc = "Power-user utilities for tweaking and boosting Windows" }
        @{ Name = "Xournal++"; Id = "Xournal++.Xournal++"; Desc = "Note-taking and PDF annotation tool" }
        @{ Name = "Obsidian"; Id = "Obsidian.Obsidian"; Desc = "Note-taking app built around linked markdown notes" }
        @{ Name = "Everything"; Id = "voidtools.Everything"; Desc = "Instant file and folder search across your drives" }
        @{ Name = "ShareX"; Id = "ShareX.ShareX"; Desc = "Screenshot, screen recording, and file sharing tool" }
        @{ Name = "CCleaner"; Id = "Piriform.CCleaner"; Desc = "System cleanup and optimization tool" }
        @{ Name = "TreeSize Free"; Id = "JAMSoftware.TreeSize.Free"; Desc = "Visualize what's taking up space on your disk" }
        @{ Name = "Rufus"; Id = "Rufus.Rufus"; Desc = "Create bootable USB drives for OS installs" }
        @{ Name = "qBittorrent"; Id = "qBittorrent.qBittorrent"; Desc = "Free, open-source BitTorrent client" }
        @{ Name = "Ditto"; Id = "Ditto.Ditto"; Desc = "Clipboard manager with searchable history" }
    )
    "Dev Tools & Networking" = @(
        @{ Name = "Git"; Id = "Git.Git"; Desc = "Version control system for tracking code changes" }
        @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Desc = "Lightweight, extensible code editor" }
        @{ Name = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS"; Desc = "JavaScript runtime for building server-side and tooling apps" }
        @{ Name = "Python 3"; Id = "Python.Python.3.12"; Desc = "General-purpose programming language and runtime" }
        @{ Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal"; Desc = "Modern, tabbed terminal app for Windows" }
        @{ Name = "Docker Desktop"; Id = "Docker.DockerDesktop"; Desc = "Build and run containerized applications" }
        @{ Name = "Postman"; Id = "Postman.Postman"; Desc = "API development and testing tool" }
        @{ Name = "Wireshark"; Id = "WiresharkFoundation.Wireshark"; Desc = "Network protocol analyzer for packet inspection" }
        @{ Name = "IntelliJ IDEA Community"; Id = "JetBrains.IntelliJIDEA.Community"; Desc = "Full-featured IDE for Java and JVM languages" }
        @{ Name = "PyCharm Community"; Id = "JetBrains.PyCharm.Community"; Desc = "IDE built specifically for Python development" }
        @{ Name = "MongoDB Compass"; Id = "MongoDB.Compass"; Desc = "GUI for exploring and managing MongoDB databases" }
        @{ Name = "DBeaver"; Id = "dbeaver.dbeaver"; Desc = "Universal database management tool" }
        @{ Name = "Insomnia"; Id = "Insomnia.Insomnia"; Desc = "API client for designing and testing REST/GraphQL APIs" }
        @{ Name = "Windows Subsystem for Linux"; Id = "Microsoft.WSL"; Desc = "Run a Linux environment directly on Windows" }
        @{ Name = "PuTTY"; Id = "PuTTY.PuTTY"; Desc = "SSH and telnet client for remote connections" }
    )
    "Streaming & Creative" = @(
        @{ Name = "OBS Studio"; Id = "OBSProject.OBSStudio"; Desc = "Free software for live streaming and screen recording" }
        @{ Name = "Streamlabs OBS"; Id = "Streamlabs.StreamlabsOBS"; Desc = "Streaming software with built-in overlays and alerts" }
        @{ Name = "GIMP"; Id = "GIMP.GIMP"; Desc = "Free, powerful image editing software" }
        @{ Name = "Blender"; Id = "BlenderFoundation.Blender"; Desc = "Free 3D modeling, animation, and rendering suite" }
        @{ Name = "Audacity"; Id = "Audacity.Audacity"; Desc = "Free audio recording and editing software" }
        @{ Name = "DaVinci Resolve"; Id = "Blackmagicdesign.DaVinciResolve"; Desc = "Professional video editing and color grading suite" }
        @{ Name = "Krita"; Id = "KDE.Krita"; Desc = "Free digital painting and illustration software" }
    )
}

# ---- Build the grouped checkbox XAML dynamically (nothing checked) ----
# Descriptions are shown as tooltips on hover.
function ConvertTo-XamlSafe {
    param([string]$Text)
    return $Text.Replace("&", "&amp;").Replace('"', "&quot;").Replace("<", "&lt;").Replace(">", "&gt;")
}

$groupXaml = ""
foreach ($category in $Categories.Keys) {
    $upperCat = ConvertTo-XamlSafe ($category.ToUpper())
    $groupXaml += "<TextBlock Text=`"$upperCat`" Style=`"{StaticResource CategoryHeader}`"/>`n"
    foreach ($app in $Categories[$category]) {
        $safeName = ConvertTo-XamlSafe $app.Name
        $safeDesc = ConvertTo-XamlSafe $app.Desc
        $groupXaml += "<CheckBox Content=`"$safeName`" Tag=`"$($app.Id)`" IsChecked=`"False`" ToolTip=`"$safeDesc`"/>`n"
    }
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinSpark" Height="720" Width="460"
        WindowStartupLocation="CenterScreen"
        Background="#0F0F17"
        FontFamily="Segoe UI">
    <Window.Resources>

        <SolidColorBrush x:Key="AccentBrush" Color="#6366F1"/>
        <SolidColorBrush x:Key="AccentHoverBrush" Color="#7C7FF5"/>
        <SolidColorBrush x:Key="DangerBrush" Color="#DC4C4C"/>
        <SolidColorBrush x:Key="DangerHoverBrush" Color="#E86B6B"/>
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

        <Style x:Key="DangerButton" TargetType="Button" BasedOn="{StaticResource ModernButton}">
            <Setter Property="Background" Value="{StaticResource DangerBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource DangerBrush}"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{TemplateBinding Background}" CornerRadius="7">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource DangerHoverBrush}"/>
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

        <Style TargetType="ToolTip">
            <Setter Property="Background" Value="{StaticResource SurfaceAltBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource TextBrush}"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="8,5"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ToolTip">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{StaticResource BorderBrush2}"
                                BorderThickness="1" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="150"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,0,0,10">
            <TextBlock Text="WinSpark" FontSize="22" FontWeight="Bold" Foreground="{StaticResource TextBrush}"/>
            <TextBlock Text="Pick what you want installed or removed. Nothing runs until you say so." FontSize="12" Foreground="{StaticResource MutedTextBrush}" Margin="0,2,0,0"/>
        </StackPanel>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel x:Name="CheckboxPanel">
                $groupXaml
            </StackPanel>
        </ScrollViewer>

        <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,14,0,8">
            <Button x:Name="SelectAllBtn" Content="Select All" Width="100" Margin="0,0,8,0" Style="{StaticResource ModernButton}"/>
            <Button x:Name="SelectNoneBtn" Content="Select None" Width="100" Margin="0,0,8,0" Style="{StaticResource ModernButton}"/>
        </StackPanel>

        <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="0,0,0,10">
            <Button x:Name="InstallBtn" Content="Install Selected" Width="150" Margin="0,0,8,0" Style="{StaticResource AccentButton}"/>
            <Button x:Name="UninstallBtn" Content="Uninstall Selected" Width="150" Style="{StaticResource DangerButton}"/>
        </StackPanel>

        <Grid Grid.Row="4" Margin="0,0,0,10">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <ProgressBar x:Name="ProgressBar" Grid.Row="0" Minimum="0" Maximum="100" Value="0"/>
            <TextBlock x:Name="ProgressLabel" Grid.Row="1" Text="" FontSize="11" Foreground="{StaticResource MutedTextBrush}" Margin="0,6,0,0" HorizontalAlignment="Center"/>
        </Grid>

        <TextBox x:Name="LogBox" Grid.Row="5" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$checkboxPanel  = $window.FindName("CheckboxPanel")
$selectAllBtn   = $window.FindName("SelectAllBtn")
$selectNoneBtn  = $window.FindName("SelectNoneBtn")
$installBtn     = $window.FindName("InstallBtn")
$uninstallBtn   = $window.FindName("UninstallBtn")
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

function Set-ButtonsEnabled {
    param([bool]$Enabled)
    $installBtn.IsEnabled = $Enabled
    $uninstallBtn.IsEnabled = $Enabled
    $selectAllBtn.IsEnabled = $Enabled
    $selectNoneBtn.IsEnabled = $Enabled
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

    Set-ButtonsEnabled $false

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

    Set-ButtonsEnabled $true

    [System.Windows.Forms.MessageBox]::Show(
        "Install finished.`n`nSucceeded: $succeeded`nFailed: $failed",
        "WinSpark",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$uninstallBtn.Add_Click({
    $selected = Get-CheckBoxes | Where-Object { $_.IsChecked -eq $true }

    if ($selected.Count -eq 0) {
        Write-GuiLog "No apps selected."
        return
    }

    $names = ($selected | ForEach-Object { $_.Content }) -join "`n"
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "This will uninstall $($selected.Count) app(s):`n`n$names`n`nContinue?",
        "Confirm Uninstall",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-GuiLog "Uninstall cancelled."
        return
    }

    Set-ButtonsEnabled $false

    $total = $selected.Count
    $done = 0
    $succeeded = 0
    $failed = 0

    $progressBar.Value = 0
    $progressBar.Maximum = $total
    Write-GuiLog "Starting uninstall of $total app(s)..."

    foreach ($cb in $selected) {
        $name = $cb.Content
        $id = $cb.Tag

        $progressLabel.Text = "Uninstalling $name  ($($done + 1) of $total)"
        [System.Windows.Forms.Application]::DoEvents()

        Write-GuiLog "Uninstalling $name..."

        $result = winget uninstall --id $id --silent --accept-source-agreements -e 2>&1
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-GuiLog "  Removed: $name"
            $succeeded++
        }
        elseif ($result -match "No installed package found" -or $result -match "not installed") {
            Write-GuiLog "  Not installed: $name"
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

    Set-ButtonsEnabled $true

    [System.Windows.Forms.MessageBox]::Show(
        "Uninstall finished.`n`nSucceeded: $succeeded`nFailed: $failed",
        "WinSpark",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$window.ShowDialog() | Out-Null
