<#
.SYNOPSIS
    Bootstraps the Windows shell environment by:
    - Setting up PowerShell profile
    - Installing Starship via winget
    - Downloading Starship config
    - Creating devcontainer aliases and helper script
#>

$dotfilesDir = "$HOME\dotfiles"
$binDir = "$HOME\bin"
$profilePath = $PROFILE
$devaliasesPath = "$HOME\.devaliases.ps1"

# Ensure dotfiles exists
if (-not (Test-Path $dotfilesDir)) {
    git clone "git@github.com:kfuras/dotfiles.git" $dotfilesDir
}

# Create PowerShell profile if it doesn't exist
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}

# Ensure Starship is installed
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Starship via winget..."
    winget install --id Starship.Starship -e --accept-package-agreements --accept-source-agreements
}

# Link or copy Starship config
$starshipSource = "$dotfilesDir\.config\starship\starship.toml"
$starshipTarget = "$HOME\.config\starship.toml"
New-Item -ItemType Directory -Path (Split-Path $starshipTarget) -Force | Out-Null
Copy-Item -Path $starshipSource -Destination $starshipTarget -Force

# Ensure profile sources Starship
$starshipInit = 'Invoke-Expression (&starship init powershell)'
if (-not (Get-Content $profilePath | Select-String -Pattern [regex]::Escape($starshipInit))) {
    Add-Content -Path $profilePath -Value "`n$starshipInit"
    Write-Output "✅ Added Starship init to profile"
}

# --- Write .devaliases.ps1 ---
@'
# ~/.devaliases.ps1

function devsetup {
    param([string]$type)
    & "$HOME\bin\add-devcontainer.ps1" --type=$type
}

function devconnect {
    param([string]$name)
    $container = docker ps --filter "name=$name" --format "{{.Names}}" | Select-Object -First 1
    if (-not $container) {
        Write-Host "❌ No container found matching: $name"
        return
    }
    docker exec -it $container powershell
}
'@ | Set-Content $devaliasesPath

# Source aliases in profile
$devaliasesSource = ". $devaliasesPath"
if (-not (Get-Content $profilePath | Select-String -Pattern [regex]::Escape($devaliasesSource))) {
    Add-Content -Path $profilePath -Value "`n$devaliasesSource"
    Write-Output "✅ Added dev aliases to profile"
}

# Create bin directory and download helper script
New-Item -ItemType Directory -Path $binDir -Force | Out-Null
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kfuras/lab/main/powershell/add-devcontainer.ps1" -OutFile "$binDir\add-devcontainer.ps1"

Write-Output "✅ Setup complete. Restart your terminal to apply changes."
