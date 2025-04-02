#!/bin/bash

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
LAB_SCRIPTS_DIR="$HOME/code/lab/bash"
ZSHRC_PATH="$HOME/.zshrc"
BASHRC_PATH="$HOME/.bashrc"

# --- Link or append shell config ---
if [[ "$SHELL" =~ "zsh" ]]; then
  touch "$ZSHRC_PATH"
  if ! grep -q "# >>> dotfiles <<<" "$ZSHRC_PATH"; then
    echo -e "\n# >>> dotfiles <<<\nsource \"$DOTFILES_DIR/.zshrc\"\n# <<< dotfiles >>>" >> "$ZSHRC_PATH"
    echo "✅ Appended dotfiles config to .zshrc"
  else
    echo "ℹ️  .zshrc already sources dotfiles"
  fi
elif [[ "$SHELL" =~ "bash" ]]; then
  touch "$BASHRC_PATH"
  ln -sf "$DOTFILES_DIR/.bashrc" "$BASHRC_PATH"
  ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  echo "✅ Linked .bashrc and .bash_aliases"
fi

# --- Setup Starship ---
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

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
  touch "$ZSHRC_PATH"
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$ZSHRC_PATH" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$ZSHRC_PATH"
elif [[ "$SHELL" =~ "bash" ]]; then
  touch "$BASHRC_PATH"
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$BASHRC_PATH" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$BASHRC_PATH"
fi

# --- Symlink devcontainer helper ---
mkdir -p "$HOME/bin"
ln -sf "$LAB_SCRIPTS_DIR/add-devcontainer.sh" "$HOME/bin/add-devcontainer"
echo "✅ Linked add-devcontainer.sh to ~/bin/add-devcontainer"

exec "$SHELL"
