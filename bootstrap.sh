#!/bin/bash

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
LAB_SCRIPTS_DIR="$HOME/code/lab/bash"

# --- Append dotfiles to personal shell config ---
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"

if [[ "$SHELL" =~ "zsh" ]]; then
  touch "$ZSHRC"
  if ! grep -q "# >>> dotfiles <<<" "$ZSHRC"; then
    echo -e "\n# >>> dotfiles <<<\nsource \"$DOTFILES_DIR/.zshrc\"\n# <<< dotfiles >>>" >> "$ZSHRC"
    echo "✅ Appended dotfiles config to .zshrc"
  fi
elif [[ "$SHELL" =~ "bash" ]]; then
  touch "$BASHRC"
  ln -sf "$DOTFILES_DIR/.bashrc" "$BASHRC"
  ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  echo "✅ Linked .bashrc and .bash_aliases"
fi

# --- Setup Starship config ---
mkdir -p "$HOME/.config/starship"
ln -sf "$DOTFILES_DIR/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
echo "✅ Linked Starship config to ~/.config/starship/starship.toml"

# --- Install Starship if missing ---
if ! command -v starship &> /dev/null; then
  echo "⬇️  Installing Starship via Homebrew..."
  if command -v brew &> /dev/null; then
    brew install starship
  else
    echo "⚠️  Homebrew not found. Please install Starship manually."
  fi
fi

# --- Setup devcontainer aliases ---
ln -sf "$DOTFILES_DIR/.devaliases" "$HOME/.devaliases"

if [[ "$SHELL" =~ "zsh" ]]; then
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$ZSHRC" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$ZSHRC"
elif [[ "$SHELL" =~ "bash" ]]; then
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$BASHRC" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$BASHRC"
fi

# --- Link devcontainer helper script ---
mkdir -p "$HOME/bin"
ln -sf "$LAB_SCRIPTS_DIR/add-devcontainer.sh" "$HOME/bin/add-devcontainer"
echo "✅ Linked add-devcontainer.sh to ~/bin/add-devcontainer"

exec "$SHELL"
