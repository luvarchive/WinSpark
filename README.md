# QuickSetup

A simple GUI tool for setting up a new Windows PC fast. Pick the apps you want from a checklist, hit install, and it handles the rest using [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) (Windows Package Manager).

No manually hunting down installers from a dozen different websites.

## Run it

Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/Install-Essentials-GUI.ps1 | iex
```

That's it — no download, no setup. It pulls the script and runs it directly.

> Replace `YOUR-USERNAME/YOUR-REPO` with your actual GitHub path once this is uploaded.

## What it does

- Opens a window listing apps grouped by category (Browsers, Media, Communication, Utilities, Dev Tools)
- You check the boxes for what you want
- Click **Install Selected** and it installs everything silently in the background via winget
- A progress bar and live log show what's happening
- Skips anything already installed — safe to re-run anytime

## Requirements

- Windows 10 or 11
- [winget](https://apps.microsoft.com/detail/9nblggh4nns1) (comes pre-installed on most modern Windows systems; if missing, install "App Installer" from the Microsoft Store)
- Run as **Administrator** for silent installs to work properly

## Included apps

| Category | Apps |
|---|---|
| Browsers | Chrome, Firefox |
| Media | VLC, Spotify |
| Communication | Zoom, Discord |
| Utilities | 7-Zip, Adobe Acrobat Reader, Notepad++, PowerToys |
| Dev Tools | Git, VS Code, Node.js LTS, Python 3, Windows Terminal, Docker Desktop, Postman |

## Customizing the app list

Open `Install-Essentials-GUI.ps1` and edit the `$Categories` section near the top. Each entry looks like:

```powershell
@{ Name = "App Display Name"; Id = "Publisher.AppId"; Checked = $false }
```

Find the correct `Id` for any app by running:

```powershell
winget search "app name"
```

Add a new category by adding a new key to the `$Categories` ordered hashtable, or add apps to an existing one.

## Safety note

This script only installs software you explicitly check and click install for — nothing runs without your say-so. Always review scripts before running them from the internet, including this one. The raw source is right here in this repo for you to read before running.

## License

MIT — do whatever you want with it.
