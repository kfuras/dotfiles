#!/bin/bash

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"
DEVALIASES="$HOME/.devaliases"
BIN_DIR="$HOME/bin"

# --- Write ~/.devaliases ---
cat <<'EOF' > "$DEVALIASES"
# ~/.devaliases

devsetup() {
  "$HOME/bin/add-devcontainer" --type="$1"
}

devbuild() {
  if ! command -v devcontainer &> /dev/null; then
    echo "❌ devcontainer CLI not found. Install with: brew install devcontainer"
    return 1
  fi
  devcontainer up --workspace-folder "$PWD"
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

# --- Append dotfiles config to shell ---
if [[ "$SHELL" =~ "zsh" ]]; then
  touch "$ZSHRC"
  if ! grep -q "# >>> dotfiles <<<" "$ZSHRC"; then
    echo -e "\n# >>> dotfiles <<<\nsource \"$DOTFILES_DIR/.zshrc\"\n# <<< dotfiles >>>" >> "$ZSHRC"
  fi
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$ZSHRC" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$ZSHRC"
elif [[ "$SHELL" =~ "bash" ]]; then
  touch "$BASHRC"
  ln -sf "$DOTFILES_DIR/.bashrc" "$BASHRC"
  ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$BASHRC" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$BASHRC"
fi

# --- Setup Starship ---
mkdir -p "$HOME/.config/starship"
ln -sf "$DOTFILES_DIR/.config/starship/starship.toml" "$HOME/.config/starship.toml"
echo "✅ Linked Starship config"

if ! command -v starship &> /dev/null; then
  echo "⬇️  Installing Starship via Homebrew..."
  brew install starship
fi

# --- Install devcontainer CLI if missing ---
if ! command -v devcontainer &> /dev/null; then
  echo "⬇️  Installing devcontainer CLI via Homebrew..."
  brew install devcontainer
fi

# --- Download add-devcontainer.sh from GitHub lab repo ---
mkdir -p "$BIN_DIR"
curl -fsSL https://raw.githubusercontent.com/kfuras/lab/main/bash/add-devcontainer.sh -o "$BIN_DIR/add-devcontainer"
chmod +x "$BIN_DIR/add-devcontainer"
echo "✅ Downloaded add-devcontainer.sh to ~/bin"

exec "$SHELL"
