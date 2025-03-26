# Dotfiles by kfuras

A cross-platform, version-controlled setup for managing shell configurations across macOS, Linux, and Windows environments. This repository provides a unified development experience powered by `zsh`, `bash`, and the `starship` prompt.

## Features

- Shell-aware setup for both `bash` and `zsh`
- Cross-platform support (macOS, Linux, Windows)
- Fast, minimal prompt via [Starship](https://starship.rs)
- Bootstrap scripts to quickly apply configurations
- SSH key-based GitHub and server management

## Quick Start

### 1. Clone the Repository

You can use either SSH or HTTPS depending on your Git configuration:

#### Option 1: Using SSH (recommended if you have SSH keys configured)

```bash
git clone git@github.com:kfuras/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### Option 2: Using HTTPS

```bash
git clone https://github.com/kfuras/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Bootstrap Setup

#### macOS / Linux

```bash
./bootstrap.sh
```

- Symlinks `.bashrc`, `.bash_aliases`, or `.zshrc`
- Configures Starship prompt
- Applies changes to your shell

#### Windows (PowerShell)

```powershell
./bootstrap.ps1
```

- Adds Starship to your PowerShell profile
- Copies the shared `starship.toml` configuration

> **Note**  
> These scripts assume that [Starship](https://starship.rs) is already installed on your system.  
> If it’s not, you can install it manually or modify the bootstrap scripts to install it automatically.

## Tools and Technologies

- [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions)
- [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting)
- [`Starship`](https://starship.rs) for cross-shell theming

## Repository Structure

```
dotfiles/
├── .bashrc
├── .bash_aliases
├── .zshrc
├── .config/
│   └── starship.toml
├── zsh_plugins/
├── bootstrap.sh
└── bootstrap.ps1
├── LICENSE
└── README.md

```

## Keeping Dotfiles in Sync

To update configurations across systems:

```bash
cd ~/dotfiles
git pull origin main
source ~/.zshrc   # or ~/.bashrc depending on your shell
```

## License

This repository is maintained by [@kfuras](https://github.com/kfuras). You are welcome to fork or adapt it for personal or professional use.
