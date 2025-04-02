# Set paths
$dotfilesDir = "$HOME\code\dotfiles"
$labScriptsDir = "$HOME\code\lab\powershell"
$profilePath = $PROFILE
$starshipToml = "$HOME\.config\starship.toml"
$devaliases = "$HOME\.devaliases.ps1"
$devHelperScript = "$HOME\bin\add-devcontainer.ps1"

# Ensure dotfiles exists
if (-not (Test-Path $dotfilesDir)) {
    git clone git@github.com:kfuras/dotfiles.git $dotfilesDir
}

# Ensure profile file exists
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}

# Install starship if missing
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Starship with winget..."
    winget install --id Starship.Starship -e --source winget
}

# Copy Starship config
$sourceToml = "$dotfilesDir\.config\starship.toml"
if (Test-Path $sourceToml) {
    New-Item -ItemType Directory -Force -Path (Split-Path $starshipToml)
    Copy-Item -Path $sourceToml -Destination $starshipToml -Force
    Write-Host "✅ Starship config copied"
}

# Add Starship init to profile if not already added
$starshipInit = 'Invoke-Expression (&starship init powershell)'
if (-not (Get-Content $profilePath | Select-String -Pattern $starshipInit)) {
    Add-Content -Path $profilePath -Value "`n$starshipInit"
    Write-Host "✅ Starship init added to profile"
}

# Link .devaliases.ps1
$sourceDevaliases = "$dotfilesDir\.devaliases.ps1"
if (Test-Path $sourceDevaliases) {
    if (-not (Get-Content $profilePath | Select-String -Pattern "\.devaliases\.ps1")) {
        Add-Content -Path $profilePath -Value "`n. '$devaliases'"
        Write-Host "✅ Added .devaliases.ps1 sourcing to profile"
    }
    Copy-Item -Path $sourceDevaliases -Destination $devaliases -Force
}

# Add add-devcontainer.ps1 helper
New-Item -ItemType Directory -Force -Path "$HOME\bin"
$addDevSource = "$labScriptsDir\add-devcontainer.ps1"
if (Test-Path $addDevSource) {
    Copy-Item -Path $addDevSource -Destination $devHelperScript -Force
    Write-Host "✅ Linked add-devcontainer.ps1 to ~/bin"
}

Write-Host "`n🔁 Reload your PowerShell session or run: `n`n    . $PROFILE`n"
