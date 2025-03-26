$dotfilesDir = "$HOME\dotfiles"

if (-not (Test-Path $dotfilesDir)) {
    git clone https://github.com/kfuras/dotfiles.git $dotfilesDir
}

$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}
$starshipInit = 'Invoke-Expression (&starship init powershell)'
if (-not (Get-Content $profilePath | Select-String -Pattern $starshipInit)) {
    Add-Content -Path $profilePath -Value $starshipInit
}

$starshipTomlPath = "$HOME\.config\starship.toml"
$sourceToml = "$dotfilesDir\.config\starship.toml"
Copy-Item $sourceToml $starshipTomlPath -Force
