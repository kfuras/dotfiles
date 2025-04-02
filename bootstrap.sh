#!/bin/bash

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
LAB_SCRIPTS_DIR="$HOME/code/lab/bash"

# --- Link shell config files ---
if [[ "$SHELL" =~ "zsh" ]]; then
  ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  echo "✅ Linked .zshrc"
elif [[ "$SHELL" =~ "bash" ]]; then
  ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
  ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  echo "✅ Linked .bashrc and .bash_aliases"
fi

# --- Setup Starship config ---
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# --- Install Starship if missing ---
if ! command -v starship &> /dev/null; then
  echo "⬇️  Installing Starship via Homebrew..."
  if command -v brew &> /dev/null; then
    brew install starship
  else
    echo "⚠️  Homebrew not found. Please install Starship manually."
  fi
fi

# --- Link devcontainer alias file ---
ln -sf "$DOTFILES_DIR/.devaliases" "$HOME/.devaliases"

# --- Add source to shell startup file ---
if [[ "$SHELL" =~ "zsh" ]] && ! grep -q "source ~/.devaliases" "$HOME/.zshrc"; then
  echo "[ -f ~/.devaliases ] && source ~/.devaliases" >> "$HOME/.zshrc"
elif [[ "$SHELL" =~ "bash" ]] && ! grep -q "source ~/.devaliases" "$HOME/.bashrc"; then
  echo "[ -f ~/.devaliases ] && source ~/.devaliases" >> "$HOME/.bashrc"
fi

# --- Optional: Symlink the add-devcontainer.sh helper from lab repo ---
mkdir -p "$HOME/bin"
ln -sf "$LAB_SCRIPTS_DIR/add-devcontainer.sh" "$HOME/bin/add-devcontainer"
echo "✅ Linked add-devcontainer.sh to ~/bin/add-devcontainer"

exec "$SHELL"
