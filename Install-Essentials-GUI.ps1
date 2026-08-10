<#
.SYNOPSIS
    WinSpark - Ultra-Modern GUI system utility for winget apps and Windows optimization.
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# ---- Check winget is available ----
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    [System.Windows.Forms.MessageBox]::Show(
        "winget was not found on this system.`n`nInstall 'App Installer' from the Microsoft Store.",
        "winget Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

# ---- App List & Tweaks ----
$Categories = [ordered]@{
    "Browsers & Web" = @(
        @{ Name = "Google Chrome"; Id = "Google.Chrome"; Desc = "Fast, widely-used browser" }
        @{ Name = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Desc = "Open-source privacy browser" }
        @{ Name = "Brave"; Id = "Brave.Brave"; Desc = "Privacy browser with ad blocker" }
        @{ Name = "Vivaldi"; Id = "VivaldiTechnologies.Vivaldi"; Desc = "Highly customizable browser for power users" }
        @{ Name = "Opera GX"; Id = "Opera.OperaGX"; Desc = "Browser built specifically for gamers" }
        @{ Name = "Thorium"; Id = "Alex313031.Thorium"; Desc = "Compiler-optimized, high-performance Chromium fork" }
        @{ Name = "Floorp"; Id = "Ablaze.Floorp"; Desc = "Advanced Firefox derivative focused on customization" }
        @{ Name = "LibreWolf"; Id = "LibreWolf.LibreWolf"; Desc = "Customized version of Firefox focused on privacy" }
        @{ Name = "Tor Browser"; Id = "TorProject.TorBrowser"; Desc = "Anonymized browsing through the Tor network" }
        @{ Name = "Mullvad Browser"; Id = "MullvadVPN.MullvadBrowser"; Desc = "Privacy-focused browser created with Tor Project" }
        @{ Name = "Waterfox"; Id = "Waterfox.Waterfox"; Desc = "Privacy-focused browser with legacy extension support" }
    )
    "Gaming & Esports" = @(
        @{ Name = "Steam"; Id = "Valve.Steam"; Desc = "The ultimate entertainment platform" }
        @{ Name = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher"; Desc = "Store and game launcher" }
        @{ Name = "Ubisoft Connect"; Id = "Ubisoft.Connect"; Desc = "Launcher for Ubisoft titles" }
        @{ Name = "Xbox App"; Id = "Microsoft.XboxApp"; Desc = "Xbox Game Pass and social client" }
        @{ Name = "GOG Galaxy"; Id = "GOG.Galaxy"; Desc = "DRM-free gaming and universal launcher" }
        @{ Name = "EA app"; Id = "ElectronicArts.EADesktop"; Desc = "Launcher for Electronic Arts titles" }
        @{ Name = "Riot Client"; Id = "RiotGames.RiotClient"; Desc = "Launcher for Valorant and League of Legends" }
        @{ Name = "FACEIT"; Id = "FACEIT.FACEIT"; Desc = "Competitive matchmaking platform for tactical shooters" }
        @{ Name = "Aimlabs"; Id = "StateSpace.Aimlabs"; Desc = "Aim training software for FPS games" }
        @{ Name = "Overwolf"; Id = "Overwolf.Overwolf"; Desc = "In-game overlays and stat trackers" }
        @{ Name = "Medal"; Id = "Medal.Medal"; Desc = "Record and clip gameplay automatically" }
        @{ Name = "Outplayed"; Id = "Overwolf.Outplayed"; Desc = "Automatic game clipping and recording" }
        @{ Name = "Parsec"; Id = "Parsec.Parsec"; Desc = "Ultra-low latency remote desktop for gaming" }
        @{ Name = "Moonlight"; Id = "MoonlightGameStreamingProject.Moonlight"; Desc = "Open-source Nvidia GameStream client" }
        @{ Name = "CurseForge"; Id = "Overwolf.CurseForge"; Desc = "Mod manager for various games" }
        @{ Name = "Mod Organizer 2"; Id = "ModOrganizer2.ModOrganizer2"; Desc = "Advanced mod manager for Bethesda games" }
        @{ Name = "Radmin VPN"; Id = "Famatech.RadminVPN"; Desc = "Free virtual private network for LAN gaming" }
        @{ Name = "Logitech G HUB"; Id = "Logitech.GHUB"; Desc = "Customize peripherals and controller layouts" }
        @{ Name = "Razer Synapse"; Id = "Razer.Synapse"; Desc = "Hardware configuration tool" }
        @{ Name = "Wootility"; Id = "Wooting.Wootility"; Desc = "Configuration software for analog keyboards" }
    )
    "Development & Frameworks" = @(
        @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Desc = "Lightweight code editor" }
        @{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Desc = "Source code and text editor" }
        @{ Name = "Sublime Text"; Id = "SublimeHQ.SublimeText.4"; Desc = "Sophisticated text editor for code" }
        @{ Name = "Neovim"; Id = "Neovim.Neovim"; Desc = "Highly extensible Vim-based text editor" }
        @{ Name = "Git"; Id = "Git.Git"; Desc = "Version control system" }
        @{ Name = "GitHub Desktop"; Id = "GitHub.GitHubDesktop"; Desc = "Streamline your GitHub workflow" }
        @{ Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal"; Desc = "Modern terminal app" }
        @{ Name = "Node.js (LTS)"; Id = "OpenJS.NodeJS.LTS"; Desc = "JavaScript runtime built on Chrome's V8 engine" }
        @{ Name = "NVM for Windows"; Id = "CoreyButler.NVMforWindows"; Desc = "Node Version Manager for Windows" }
        @{ Name = "Yarn"; Id = "Yarn.Yarn"; Desc = "Fast, reliable, and secure dependency management" }
        @{ Name = "pnpm"; Id = "pnpm.pnpm"; Desc = "Fast, disk space efficient package manager" }
        @{ Name = "Electron Fiddle"; Id = "Electron.ElectronFiddle"; Desc = "The easiest way to get started with Electron" }
        @{ Name = "Python 3"; Id = "Python.Python.3.12"; Desc = "General-purpose programming language" }
        @{ Name = "Docker Desktop"; Id = "Docker.DockerDesktop"; Desc = "Build and run containerized applications" }
        @{ Name = "Postman"; Id = "Postman.Postman"; Desc = "API development and testing environment" }
        @{ Name = "Insomnia"; Id = "Insomnia.Insomnia"; Desc = "API client for designing REST and GraphQL APIs" }
        @{ Name = "DBeaver"; Id = "dbeaver.dbeaver"; Desc = "Universal database management tool" }
        @{ Name = "DB Browser for SQLite"; Id = "DBBrowserForSQLite.DBBrowserForSQLite"; Desc = "Visual tool for managing SQLite databases" }
        @{ Name = "Wireshark"; Id = "WiresharkFoundation.Wireshark"; Desc = "Network protocol analyzer" }
        @{ Name = "Fiddler Classic"; Id = "Telerik.Fiddler"; Desc = "Web debugging proxy tool" }
        @{ Name = "Inno Setup"; Id = "jrsoftware.InnoSetup"; Desc = "Create custom installers for packaged Windows executables" }
        @{ Name = "VirtualBox"; Id = "Oracle.VirtualBox"; Desc = "Powerful x86 and AMD64/Intel64 virtualization" }
        @{ Name = "Sysinternals Suite"; Id = "Microsoft.Sysinternals"; Desc = "Advanced system utilities including Process Explorer" }
        @{ Name = "System Informer"; Id = "SystemInformer.SystemInformer"; Desc = "Advanced task manager and process analyzer" }
    )
    "Hardware & Diagnostics" = @(
        @{ Name = "HWiNFO64"; Id = "REALiX.HWiNFO"; Desc = "In-depth hardware analysis and monitoring" }
        @{ Name = "CPU-Z"; Id = "CPUID.CPU-Z"; Desc = "Gathers information on your processor and motherboard" }
        @{ Name = "GPU-Z"; Id = "TechPowerUp.GPU-Z"; Desc = "Lightweight video card diagnostic utility" }
        @{ Name = "Core Temp"; Id = "ALCPU.CoreTemp"; Desc = "Monitor CPU temperatures in real-time" }
        @{ Name = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Desc = "HDD/SSD health monitoring utility" }
        @{ Name = "CrystalDiskMark"; Id = "CrystalDewWorld.CrystalDiskMark"; Desc = "Storage drive benchmark utility" }
        @{ Name = "MSI Afterburner"; Id = "MSI.Afterburner"; Desc = "Graphics card overclocking and fan control" }
        @{ Name = "FanControl"; Id = "Rem0o.FanControl"; Desc = "Highly customizable fan controlling software" }
        @{ Name = "ThrottleStop"; Id = "KevinGlynn.ThrottleStop"; Desc = "Monitor and resolve CPU throttling issues" }
        @{ Name = "Cinebench R23"; Id = "Maxon.CinebenchR23"; Desc = "Hardware benchmarking tool for CPU rendering" }
        @{ Name = "Prime95"; Id = "Mersenne.Prime95"; Desc = "Heavy CPU stress-testing utility" }
        @{ Name = "OCCT"; Id = "OCBASE.OCCT"; Desc = "All-in-one stability checking and stress testing" }
        @{ Name = "AIDA64 Extreme"; Id = "FinalWire.AIDA64.Extreme"; Desc = "Industry-leading system information tool" }
        @{ Name = "USBDeview"; Id = "NirSoft.USBDeview"; Desc = "Manage and troubleshoot connected USB devices" }
        @{ Name = "USB Tree View"; Id = "UweSieber.USBTreeView"; Desc = "Detailed view of USB host controllers and devices" }
        @{ Name = "LatencyMon"; Id = "Resplendence.LatencyMon"; Desc = "Analyzes system for DPC latency causing audio/hardware drops" }
        @{ Name = "Speccy"; Id = "Piriform.Speccy"; Desc = "Fast, lightweight, advanced system information tool" }
        @{ Name = "Rufus"; Id = "Rufus.Rufus"; Desc = "Create bootable USB drives" }
        @{ Name = "Ventoy"; Id = "Ventoy.Ventoy"; Desc = "Create multi-boot USB drives for ISO/WIM files" }
    )
    "Audio & Media" = @(
        @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Desc = "Plays virtually any audio or video format" }
        @{ Name = "Spotify"; Id = "Spotify.Spotify"; Desc = "Music and podcast streaming service" }
        @{ Name = "MusicBee"; Id = "MusicBee.MusicBee"; Desc = "Ultimate music manager and player for large local libraries" }
        @{ Name = "foobar2000"; Id = "PeterPawlowski.foobar2000"; Desc = "Advanced freeware audio player" }
        @{ Name = "Strawberry"; Id = "strawberrymusicplayer.strawberry"; Desc = "Audio player and music collection organizer" }
        @{ Name = "Mp3tag"; Id = "FlorianHeidenreich.Mp3tag"; Desc = "Powerful tool to edit audio metadata and cover art" }
        @{ Name = "Voicemeeter"; Id = "VB-Audio.Voicemeeter"; Desc = "Virtual audio mixer and routing tool" }
        @{ Name = "Equalizer APO"; Id = "jthedering.EqualizerAPO"; Desc = "System-wide parametric equalizer for Windows" }
        @{ Name = "Peace Equalizer"; Id = "PeterVerbeek.Peace"; Desc = "GUI for Equalizer APO to tune audio profiles" }
        @{ Name = "Audacity"; Id = "Audacity.Audacity"; Desc = "Free software for multitrack audio recording and editing" }
        @{ Name = "OBS Studio"; Id = "OBSProject.OBSStudio"; Desc = "Free software for video recording and live streaming" }
        @{ Name = "HandBrake"; Id = "HandBrake.HandBrake"; Desc = "Open-source video transcoder" }
        @{ Name = "Jellyfin Media Player"; Id = "Jellyfin.JellyfinMediaPlayer"; Desc = "Desktop client for Jellyfin media servers" }
        @{ Name = "Plex"; Id = "Plex.Plex"; Desc = "Client for Plex media servers" }
        @{ Name = "Stremio"; Id = "Stremio.Stremio"; Desc = "Modern media center for video entertainment" }
        @{ Name = "Taiga"; Id = "erengy.Taiga"; Desc = "Lightweight anime tracker and scrobbler for Windows" }
        @{ Name = "HakuNeko"; Id = "HakuNeko.HakuNeko"; Desc = "Manga and anime downloader" }
        @{ Name = "K-Lite Codec Pack"; Id = "CodecGuide.K-LiteCodecPack.Mega"; Desc = "Comprehensive audio and video codec library" }
    )
    "Design & Customization" = @(
        @{ Name = "Figma"; Id = "Figma.Figma"; Desc = "Collaborative interface design tool" }
        @{ Name = "GIMP"; Id = "GIMP.GIMP"; Desc = "Free, powerful image editing software" }
        @{ Name = "Paint.NET"; Id = "dotPDNLLC.paint.net"; Desc = "Image and photo editing software" }
        @{ Name = "Inkscape"; Id = "Inkscape.Inkscape"; Desc = "Professional vector graphics editor" }
        @{ Name = "Krita"; Id = "KDE.Krita"; Desc = "Professional, free and open source painting program" }
        @{ Name = "Blender"; Id = "BlenderFoundation.Blender"; Desc = "3D modeling, animation, and rendering suite" }
        @{ Name = "IrfanView"; Id = "IrfanSkiljan.IrfanView"; Desc = "Fast and compact image viewer" }
        @{ Name = "PureRef"; Id = "IdyllicPixel.PureRef"; Desc = "Simple and lightweight tool to organize your reference images" }
        @{ Name = "Rainmeter"; Id = "Rainmeter.Rainmeter"; Desc = "Desktop customization tool for widgets and skins" }
        @{ Name = "Lively Wallpaper"; Id = "rocksdanister.LivelyWallpaper"; Desc = "Free and open-source animated wallpaper application" }
        @{ Name = "TaskbarX"; Id = "ChrisAnd1998.TaskbarX"; Desc = "Center taskbar icons and change taskbar styling" }
        @{ Name = "RoundedTB"; Id = "TorchGM.RoundedTB"; Desc = "Adds margins and rounded corners to your taskbar" }
    )
    "Communication" = @(
        @{ Name = "Discord"; Id = "Discord.Discord"; Desc = "Voice, video, and text chat" }
        @{ Name = "Telegram"; Id = "Telegram.TelegramDesktop"; Desc = "Fast and secure desktop messaging" }
        @{ Name = "Slack"; Id = "SlackTechnologies.Slack"; Desc = "Team messaging and collaboration platform" }
        @{ Name = "Zoom"; Id = "Zoom.Zoom"; Desc = "Video conferencing and online meetings" }
        @{ Name = "WhatsApp"; Id = "WhatsApp.WhatsApp"; Desc = "Desktop client for WhatsApp" }
        @{ Name = "Signal"; Id = "OpenWhisperSystems.Signal"; Desc = "End-to-end encrypted messaging" }
        @{ Name = "TeamSpeak"; Id = "TeamSpeakSystems.TeamSpeak3"; Desc = "VoIP communication system for online gaming" }
        @{ Name = "Element"; Id = "Element.Element"; Desc = "Secure collaboration and messaging app based on Matrix" }
    )
    "Productivity & Utilities" = @(
        @{ Name = "7-Zip"; Id = "7zip.7zip"; Desc = "Free file archiver" }
        @{ Name = "PowerToys"; Id = "Microsoft.PowerToys"; Desc = "Power-user utilities for Windows" }
        @{ Name = "Everything"; Id = "voidtools.Everything"; Desc = "Instant file search" }
        @{ Name = "Revo Uninstaller"; Id = "VSRevoGroup.RevoUninstallerFree"; Desc = "Completely remove unwanted programs and registry leftovers" }
        @{ Name = "Bulk Crap Uninstaller"; Id = "Klocman.BulkCrapUninstaller"; Desc = "Excellent bulk application uninstaller" }
        @{ Name = "Bitwarden"; Id = "Bitwarden.Bitwarden"; Desc = "Secure and free password manager" }
        @{ Name = "KeePassXC"; Id = "KeePassXCTeam.KeePassXC"; Desc = "Cross-platform community-driven password manager" }
        @{ Name = "Obsidian"; Id = "Obsidian.Obsidian"; Desc = "Knowledge base that works on local Markdown files" }
        @{ Name = "Notion"; Id = "Notion.Notion"; Desc = "All-in-one workspace for notes and tasks" }
        @{ Name = "ShareX"; Id = "ShareX.ShareX"; Desc = "Advanced screen capture and file sharing" }
        @{ Name = "WizTree"; Id = "AntibodySoftware.WizTree"; Desc = "Extremely fast disk space analyzer" }
        @{ Name = "TeraCopy"; Id = "CodeSector.TeraCopy"; Desc = "Utility designed to copy files faster and more securely" }
        @{ Name = "AutoHotkey"; Id = "AutoHotkey.AutoHotkey"; Desc = "Ultimate automation scripting language for Windows" }
        @{ Name = "EarTrumpet"; Id = "File-New-Project.EarTrumpet"; Desc = "Advanced volume control per-application" }
        @{ Name = "qBittorrent"; Id = "qBittorrent.qBittorrent"; Desc = "Free and reliable P2P BitTorrent client" }
        @{ Name = "FileZilla"; Id = "TimKosse.FileZilla.Client"; Desc = "Fast and reliable cross-platform FTP/SFTP client" }
        @{ Name = "WinSCP"; Id = "MartinPrikryl.WinSCP"; Desc = "Free SFTP, SCP, and FTP client" }
        @{ Name = "PuTTY"; Id = "PuTTY.PuTTY"; Desc = "SSH and telnet client" }
        @{ Name = "AnyDesk"; Id = "AnyDeskSoftwareGmbH.AnyDesk"; Desc = "Fast remote desktop application" }
        @{ Name = "RustDesk"; Id = "RustDesk.RustDesk"; Desc = "Open-source remote desktop software" }
        @{ Name = "SumatraPDF"; Id = "SumatraPDF.SumatraPDF"; Desc = "Lightweight PDF, eBook, and comic reader" }
        @{ Name = "BleachBit"; Id = "BleachBit.BleachBit"; Desc = "Frees disk space and guards your privacy" }
    )
}

$Tweaks = @(
    @{ Name = "Enable Ultimate Performance"; Id = "Tweak_Power"; Desc = "Prevents CPU micro-stutters."; Script = { powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null; $s = powercfg -aliases | Select-String "ULTIMATE"; if ($s) { powercfg -setactive (($s -split '\s+')[0]) } } }
    @{ Name = "Disable Telemetry"; Id = "Tweak_Telemetry"; Desc = "Stops diagnostic data collection."; Script = { Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue } }
    @{ Name = "Force System Dark Mode"; Id = "Tweak_Dark"; Desc = "Enables system-wide Dark Mode."; Script = { Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0 -Force; Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0 -Force } }
)

# ---- XAML Generation ----
function ConvertTo-XamlSafe([string]$Text) { return $Text.Replace("&", "&amp;").Replace('"', "&quot;").Replace("<", "&lt;").Replace(">", "&gt;") }

$appXaml = ""
foreach ($category in $Categories.Keys) {
    $catName = ConvertTo-XamlSafe $category
    $appXaml += @"
    <Border Style="{StaticResource CardBorder}">
        <StackPanel>
            <TextBlock Text="$catName" Style="{StaticResource CardHeader}"/>
"@
    foreach ($app in $Categories[$category]) {
        $safeName = ConvertTo-XamlSafe $app.Name; $safeDesc = ConvertTo-XamlSafe $app.Desc
        $appXaml += "<CheckBox Content=`"$safeName`" Tag=`"$($app.Id)`" ToolTip=`"$safeDesc`"/>`n"
    }
    $appXaml += "</StackPanel></Border>`n"
}

$tweakXaml = @"
<Border Style="{StaticResource CardBorder}">
    <StackPanel>
        <TextBlock Text="System Optimizations" Style="{StaticResource CardHeader}"/>
"@
foreach ($tweak in $Tweaks) {
    $safeName = ConvertTo-XamlSafe $tweak.Name; $safeDesc = ConvertTo-XamlSafe $tweak.Desc
    $tweakXaml += "<CheckBox Content=`"$safeName`" Tag=`"$($tweak.Id)`" ToolTip=`"$safeDesc`"/>`n"
}
$tweakXaml += "</StackPanel></Border>"

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinSpark" Height="820" Width="550"
        WindowStartupLocation="CenterScreen"
        Background="#09090E" FontFamily="Segoe UI"
        TextOptions.TextFormattingMode="Display">
    <Window.Resources>
        <!-- Color Palette -->
        <Color x:Key="AccentColor">#8B5CF6</Color>
        <SolidColorBrush x:Key="Accent" Color="{StaticResource AccentColor}"/>
        <SolidColorBrush x:Key="AccentHover" Color="#A78BFA"/>
        <SolidColorBrush x:Key="Danger" Color="#EF4444"/>
        <SolidColorBrush x:Key="DangerHover" Color="#F87171"/>
        
        <SolidColorBrush x:Key="BgDark" Color="#09090E"/>
        <SolidColorBrush x:Key="CardBg" Color="#13131A"/>
        <SolidColorBrush x:Key="CardBgHover" Color="#1A1A24"/>
        <SolidColorBrush x:Key="BorderMain" Color="#262636"/>
        <SolidColorBrush x:Key="BorderLight" Color="#33334A"/>
        
        <SolidColorBrush x:Key="TextMain" Color="#F3F4F6"/>
        <SolidColorBrush x:Key="TextMuted" Color="#9CA3AF"/>

        <!-- ScrollBar Styling -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Width" Value="8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Border Background="Transparent">
                            <Track x:Name="PART_Track" IsDirectionReversed="true">
                                <Track.Thumb>
                                    <Thumb>
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border Background="{StaticResource BorderLight}" CornerRadius="4" Margin="2,0"/>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                            </Track>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Card Container -->
        <Style x:Key="CardBorder" TargetType="Border">
            <Setter Property="Background" Value="{StaticResource CardBg}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderMain}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="10"/>
            <Setter Property="Padding" Value="15"/>
            <Setter Property="Margin" Value="0,0,0,15"/>
        </Style>
        
        <Style x:Key="CardHeader" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Margin" Value="0,0,0,12"/>
        </Style>

        <!-- Custom Tile Checkbox -->
        <Style TargetType="CheckBox">
            <Setter Property="Margin" Value="0,0,0,8"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <Border x:Name="MainBorder" Background="{StaticResource BgDark}" 
                                BorderBrush="{StaticResource BorderMain}" BorderThickness="1" 
                                CornerRadius="8" Padding="12,10">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                
                                <!-- Custom Checkmark Box -->
                                <Border x:Name="CheckBoxBorder" Width="20" Height="20" CornerRadius="6" 
                                        Background="{StaticResource CardBgHover}" BorderBrush="{StaticResource BorderLight}" 
                                        BorderThickness="1" VerticalAlignment="Center">
                                    <Path x:Name="CheckIcon" Data="M3,10 L8,15 L17,4" 
                                          Stroke="White" StrokeThickness="2.5" 
                                          StrokeStartLineCap="Round" StrokeEndLineCap="Round" StrokeLineJoin="Round" 
                                          Visibility="Collapsed" Margin="0,1,0,0"/>
                                </Border>
                                
                                <ContentPresenter Grid.Column="1" Margin="12,0,0,0" 
                                                  VerticalAlignment="Center" 
                                                  TextElement.Foreground="{StaticResource TextMuted}" 
                                                  TextElement.FontSize="13" TextElement.FontWeight="Medium"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="MainBorder" Property="BorderBrush" Value="{StaticResource BorderLight}"/>
                                <Setter TargetName="MainBorder" Property="Background" Value="{StaticResource CardBgHover}"/>
                            </Trigger>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="MainBorder" Property="BorderBrush" Value="{StaticResource Accent}"/>
                                <Setter TargetName="CheckBoxBorder" Property="Background" Value="{StaticResource Accent}"/>
                                <Setter TargetName="CheckBoxBorder" Property="BorderBrush" Value="{StaticResource Accent}"/>
                                <Setter TargetName="CheckIcon" Property="Visibility" Value="Visible"/>
                                <Setter Property="TextElement.Foreground" Value="{StaticResource TextMain}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Modern Tabs -->
        <Style TargetType="TabControl">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="TabBorder" Padding="0,0,0,8" Margin="0,0,30,0" BorderThickness="0,0,0,3" BorderBrush="Transparent">
                            <ContentPresenter x:Name="ContentSite" ContentSource="Header" 
                                              TextElement.FontSize="18" TextElement.FontWeight="Bold" 
                                              TextElement.Foreground="{StaticResource TextMuted}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="ContentSite" Property="TextElement.Foreground" Value="{StaticResource TextMain}"/>
                                <Setter TargetName="TabBorder" Property="BorderBrush" Value="{StaticResource Accent}"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ContentSite" Property="TextElement.Foreground" Value="{StaticResource TextMain}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Buttons with Glow -->
        <Style x:Key="BaseBtn" TargetType="Button">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="0,12"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{TemplateBinding Background}" CornerRadius="8">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Bd" Property="Opacity" Value="0.4"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="AccentBtn" TargetType="Button" BasedOn="{StaticResource BaseBtn}">
            <Setter Property="Background" Value="{StaticResource Accent}"/>
            <Setter Property="Effect">
                <Setter.Value>
                    <DropShadowEffect Color="{StaticResource AccentColor}" BlurRadius="15" ShadowDepth="0" Opacity="0.4"/>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{StaticResource AccentHover}"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style x:Key="DangerBtn" TargetType="Button" BasedOn="{StaticResource BaseBtn}">
            <Setter Property="Background" Value="{StaticResource Danger}"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="{StaticResource DangerHover}"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        
        <Style x:Key="GhostBtn" TargetType="Button" BasedOn="{StaticResource BaseBtn}">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderMain}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Bd" Property="Background" Value="{StaticResource CardBgHover}"/>
                                <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Progress Bar -->
        <Style TargetType="ProgressBar">
            <Setter Property="Background" Value="{StaticResource CardBg}"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Height" Value="6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Border Background="{TemplateBinding Background}" CornerRadius="3">
                            <Border x:Name="PART_Indicator" Background="{StaticResource Accent}" CornerRadius="3" HorizontalAlignment="Left">
                                <Border.Effect>
                                    <DropShadowEffect Color="{StaticResource AccentColor}" BlurRadius="8" ShadowDepth="0" Opacity="0.5"/>
                                </Border.Effect>
                            </Border>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Log TextBox -->
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="{StaticResource BgDark}"/>
            <Setter Property="Foreground" Value="#A0A0B0"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderMain}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8">
                            <ScrollViewer x:Name="PART_ContentHost"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="25,25,25,20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="130"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <Grid Grid.Row="0" Margin="0,0,0,25">
            <StackPanel>
				<TextBlock Text="WinSpark" FontSize="28" FontWeight="Black" Foreground="White"/>
                <TextBlock Text="System configuration and optimization environment." FontSize="13" Foreground="{StaticResource TextMuted}" Margin="0,4,0,0"/>
            </StackPanel>
        </Grid>

        <!-- Tabs -->
        <TabControl Grid.Row="1">
            <TabItem Header="Software Library">
                <Grid Margin="0,15,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    
                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto" Margin="0,0,-10,15" Padding="0,0,10,0">
                        <StackPanel x:Name="AppCheckboxPanel">
                            $appXaml
                        </StackPanel>
                    </ScrollViewer>

                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0" Orientation="Horizontal">
                            <Button x:Name="SelectAllAppsBtn" Content="Select All" Width="85" Margin="0,0,10,0" Style="{StaticResource GhostBtn}"/>
                            <Button x:Name="SelectNoneAppsBtn" Content="Clear" Width="85" Style="{StaticResource GhostBtn}"/>
                        </StackPanel>
                        <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right">
                            <Button x:Name="UninstallBtn" Content="Uninstall" Width="100" Margin="0,0,10,0" Style="{StaticResource DangerBtn}"/>
                            <Button x:Name="InstallBtn" Content="Install Selected" Width="130" Style="{StaticResource AccentBtn}"/>
                        </StackPanel>
                    </Grid>
                </Grid>
            </TabItem>

            <TabItem Header="System Tweaks">
                <Grid Margin="0,15,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>
                    
                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto" Margin="0,0,-10,15" Padding="0,0,10,0">
                        <StackPanel x:Name="TweakCheckboxPanel">
                            $tweakXaml
                        </StackPanel>
                    </ScrollViewer>

                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0" Orientation="Horizontal">
                            <Button x:Name="SelectAllTweaksBtn" Content="Select All" Width="85" Margin="0,0,10,0" Style="{StaticResource GhostBtn}"/>
                            <Button x:Name="SelectNoneTweaksBtn" Content="Clear" Width="85" Style="{StaticResource GhostBtn}"/>
                        </StackPanel>
                        <Button x:Name="ApplyTweaksBtn" Grid.Column="1" Content="Apply Tweaks" Width="130" HorizontalAlignment="Right" Style="{StaticResource AccentBtn}"/>
                    </Grid>
                </Grid>
            </TabItem>
        </TabControl>

        <!-- Progress -->
        <Grid Grid.Row="2" Margin="0,20,0,15">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <ProgressBar x:Name="ProgressBar" Grid.Row="0" Minimum="0" Maximum="100" Value="0"/>
            <TextBlock x:Name="ProgressLabel" Grid.Row="1" Text="Awaiting execution..." FontSize="12" Foreground="{StaticResource TextMuted}" Margin="0,8,0,0" HorizontalAlignment="Center"/>
        </Grid>

        <!-- Logs -->
        <TextBox x:Name="LogBox" Grid.Row="3" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$appCheckboxPanel    = $window.FindName("AppCheckboxPanel")
$tweakCheckboxPanel  = $window.FindName("TweakCheckboxPanel")
$selectAllAppsBtn    = $window.FindName("SelectAllAppsBtn")
$selectNoneAppsBtn   = $window.FindName("SelectNoneAppsBtn")
$installBtn          = $window.FindName("InstallBtn")
$uninstallBtn        = $window.FindName("UninstallBtn")
$selectAllTweaksBtn  = $window.FindName("SelectAllTweaksBtn")
$selectNoneTweaksBtn = $window.FindName("SelectNoneTweaksBtn")
$applyTweaksBtn      = $window.FindName("ApplyTweaksBtn")
$logBox              = $window.FindName("LogBox")
$progressBar         = $window.FindName("ProgressBar")
$progressLabel       = $window.FindName("ProgressLabel")

function Write-GuiLog([string]$Message) {
    $ts = Get-Date -Format "HH:mm:ss"
    $logBox.AppendText("[$ts] $Message`r`n")
    $logBox.ScrollToEnd()
    [System.Windows.Forms.Application]::DoEvents()
}

function Get-CheckBoxes($Panel) {
    # Recursively find all Checkboxes inside the borders/stackpanels
    $queue = New-Object System.Collections.Queue
    $queue.Enqueue($Panel)
    $list = @()
    while ($queue.Count -gt 0) {
        $node = $queue.Dequeue()
        if ($node -is [System.Windows.Controls.CheckBox]) { $list += $node }
        if ($node -is [System.Windows.Controls.Panel]) { foreach ($c in $node.Children) { $queue.Enqueue($c) } }
        if ($node -is [System.Windows.Controls.Border]) { $queue.Enqueue($node.Child) }
    }
    return $list
}

function Set-UIEnabled([bool]$Enabled) {
    $installBtn.IsEnabled = $Enabled
    $uninstallBtn.IsEnabled = $Enabled
    $applyTweaksBtn.IsEnabled = $Enabled
}

$selectAllAppsBtn.Add_Click({ foreach ($cb in (Get-CheckBoxes $appCheckboxPanel)) { $cb.IsChecked = $true } })
$selectNoneAppsBtn.Add_Click({ foreach ($cb in (Get-CheckBoxes $appCheckboxPanel)) { $cb.IsChecked = $false } })
$selectAllTweaksBtn.Add_Click({ foreach ($cb in (Get-CheckBoxes $tweakCheckboxPanel)) { $cb.IsChecked = $true } })
$selectNoneTweaksBtn.Add_Click({ foreach ($cb in (Get-CheckBoxes $tweakCheckboxPanel)) { $cb.IsChecked = $false } })

$installBtn.Add_Click({
    $selected = Get-CheckBoxes $appCheckboxPanel | Where-Object { $_.IsChecked -eq $true }
    if ($selected.Count -eq 0) { Write-GuiLog "No apps selected."; return }

    Set-UIEnabled $false
    $total = $selected.Count; $done = 0; $succeeded = 0; $failed = 0
    $progressBar.Maximum = $total; $progressBar.Value = 0

    foreach ($cb in $selected) {
        $name = $cb.Content; $id = $cb.Tag
        $progressLabel.Text = "Installing $name ($($done + 1)/$total)"
        [System.Windows.Forms.Application]::DoEvents()
        Write-GuiLog "Installing $name..."

        $result = winget install --id $id --silent --accept-source-agreements --accept-package-agreements -e 2>&1
        if ($LASTEXITCODE -eq 0) { Write-GuiLog "  Done: $name"; $succeeded++ }
        elseif ($result -match "No newer package" -or $result -match "already installed") { Write-GuiLog "  Already installed."; $succeeded++ }
        else { Write-GuiLog "  FAILED (Code $LASTEXITCODE)"; $failed++ }
        $progressBar.Value = ++$done
    }
    $progressLabel.Text = "Complete. Success: $succeeded, Failed: $failed"
    Set-UIEnabled $true
})

$uninstallBtn.Add_Click({
    $selected = Get-CheckBoxes $appCheckboxPanel | Where-Object { $_.IsChecked -eq $true }
    if ($selected.Count -eq 0) { Write-GuiLog "No apps selected."; return }

    Set-UIEnabled $false
    $total = $selected.Count; $done = 0; $succeeded = 0; $failed = 0
    $progressBar.Maximum = $total; $progressBar.Value = 0

    foreach ($cb in $selected) {
        $name = $cb.Content; $id = $cb.Tag
        $progressLabel.Text = "Uninstalling $name ($($done + 1)/$total)"
        [System.Windows.Forms.Application]::DoEvents()
        Write-GuiLog "Uninstalling $name..."

        $result = winget uninstall --id $id --silent --accept-source-agreements -e 2>&1
        if ($LASTEXITCODE -eq 0) { Write-GuiLog "  Removed: $name"; $succeeded++ }
        elseif ($result -match "No installed package" -or $result -match "not installed") { Write-GuiLog "  Not installed."; $succeeded++ }
        else { Write-GuiLog "  FAILED (Code $LASTEXITCODE)"; $failed++ }
        $progressBar.Value = ++$done
    }
    $progressLabel.Text = "Uninstall Complete."
    Set-UIEnabled $true
})

$applyTweaksBtn.Add_Click({
    $selected = Get-CheckBoxes $tweakCheckboxPanel | Where-Object { $_.IsChecked -eq $true }
    if ($selected.Count -eq 0) { Write-GuiLog "No tweaks selected."; return }

    Set-UIEnabled $false
    $total = $selected.Count; $done = 0; $succeeded = 0
    $progressBar.Maximum = $total; $progressBar.Value = 0

    foreach ($cb in $selected) {
        $name = $cb.Content; $id = $cb.Tag
        $progressLabel.Text = "Applying: $name ($($done + 1)/$total)"
        [System.Windows.Forms.Application]::DoEvents()
        Write-GuiLog "Applying $name..."

        $tweakObj = $Tweaks | Where-Object { $_.Id -eq $id }
        if ($tweakObj) {
            try { Invoke-Command -ScriptBlock $tweakObj.Script -ErrorAction Stop; Write-GuiLog "  Done"; $succeeded++ } 
            catch { Write-GuiLog "  FAILED: $($_.Exception.Message)" }
        }
        $progressBar.Value = ++$done
    }
    
    if ($selected | Where-Object { $_.Tag -eq "Tweak_Dark" }) {
        Write-GuiLog "Restarting Explorer to apply visual changes..."
        Stop-Process -Name explorer -Force
    }
    $progressLabel.Text = "Tweaks Applied."
    Set-UIEnabled $true
})

$window.ShowDialog() | Out-Null