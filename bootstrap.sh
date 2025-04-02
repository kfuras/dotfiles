#!/bin/bash

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
BIN_DIR="$HOME/bin"
DEVALIASES="$HOME/.devaliases"

echo "🔧 Setting up dotfiles environment..."

# --- Ensure ~/bin exists ---
mkdir -p "$BIN_DIR"

# --- Link Starship config ---
mkdir -p ~/.config
ln -sf "$DOTFILES_DIR/.config/starship.toml" ~/.config/starship.toml
echo "✅ Linked Starship config"

# --- Create ~/.devaliases with functions ---
cat <<'EOF' > "$DEVALIASES"
# ~/.devaliases

devsetup() {
  "$HOME/bin/add-devcontainer" --type="$1"
}

devconnect() {
  container=$(docker ps --filter "name=$1" --format "{{.Names}}" | head -n 1)
  if [ -z "$container" ]; then
    echo "❌ No container found matching: $1"
    return 1
  fi
  docker exec -it "$container" bash
}

devshell() {
  container=$(docker ps --filter "name=$1" --format "{{.Names}}" | head -n 1)
  if [ -z "$container" ]; then
    echo "❌ No container found matching: $1"
    return 1
  fi
  docker exec -it "$container" zsh
}
EOF
echo "✅ Created ~/.devaliases with devcontainer helpers"

# --- Download latest devcontainer helper ---
curl -fsSL https://raw.githubusercontent.com/kfuras/lab/main/bash/add-devcontainer.sh -o "$BIN_DIR/add-devcontainer"
chmod +x "$BIN_DIR/add-devcontainer"
echo "✅ Downloaded and prepared add-devcontainer.sh in ~/bin"

# --- Add sourcing logic to shell config ---
SHELL_RC="$HOME/.zshrc"
if [[ "$SHELL" =~ "bash" ]]; then
  SHELL_RC="$HOME/.bashrc"
fi

if ! grep -qF "[ -f ~/.devaliases ] && source ~/.devaliases" "$SHELL_RC"; then
  echo "" >> "$SHELL_RC"
  echo "[ -f ~/.devaliases ] && source ~/.devaliases" >> "$SHELL_RC"
  echo "✅ Updated $SHELL_RC to source ~/.devaliases"
fi

# --- Install Starship if not installed ---
if ! command -v starship &>/dev/null; then
  echo "⬇️  Installing Starship via Homebrew..."
  brew install starship
else
  echo "✅ Starship already installed"
fi

echo "🎉 Bootstrap complete. Restart your shell or run: source $SHELL_RC"
