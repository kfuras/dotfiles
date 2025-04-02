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

# Create devcontainer by project type
devsetup() {
  "$HOME/bin/add-devcontainer" --type="$1"
}

# Connect to container by name
devconnect() {
  container=$(docker ps --filter "name=$1" --format "{{.Names}}" | head -n 1)
  if [ -z "$container" ]; then
    echo "❌ No container found matching: $1"
    return 1
  fi
  docker exec -it "$container" bash
}

# Optional: use Zsh shell inside container
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

# --- Append dotfiles to shell config ---
if [[ "$SHELL" =~ "zsh" ]]; then
  touch "$ZSHRC"
  if ! grep -q "# >>> dotfiles <<<" "$ZSHRC"; then
    echo -e "\n# >>> dotfiles <<<\nsource \"$DOTFILES_DIR/.zshrc\"\n# <<< dotfiles >>>" >> "$ZSHRC"
    echo "✅ Appended dotfiles config to .zshrc"
  fi
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$ZSHRC" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$ZSHRC"
elif [[ "$SHELL" =~ "bash" ]]; then
  touch "$BASHRC"
  ln -sf "$DOTFILES_DIR/.bashrc" "$BASHRC"
  ln -sf "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  grep -qxF '[ -f ~/.devaliases ] && source ~/.devaliases' "$BASHRC" || echo '[ -f ~/.devaliases ] && source ~/.devaliases' >> "$BASHRC"
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

# --- Pull add-devcontainer.sh from GitHub ---
mkdir -p "$BIN_DIR"
curl -fsSL https://raw.githubusercontent.com/kfuras/lab/main/bash/add-devcontainer.sh -o "$BIN_DIR/add-devcontainer"
chmod +x "$BIN_DIR/add-devcontainer"
echo "✅ Downloaded add-devcontainer.sh to ~/bin"

exec "$SHELL"
