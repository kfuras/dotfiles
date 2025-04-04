#!/bin/bash

set -e

DOTFILES_DIR="$HOME/code/dotfiles"
BIN_DIR="$HOME/bin"
CONFIG_DIR="$HOME/.config"
GHOSTTY_CONFIG="$CONFIG_DIR/ghostty/config"
STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
BASHRC_LOCAL="$DOTFILES_DIR/.bashrc.local"
ZSHRC_LOCAL="$DOTFILES_DIR/.zshrc.local"
DEVALIASES="$HOME/.devaliases"

echo "🔧 Setting up dotfiles environment..."

# --- Ensure ~/bin exists ---
mkdir -p "$BIN_DIR"

# --- Install Starship if not installed ---
if ! command -v starship &>/dev/null; then
  echo "⬇️  Installing Starship via Homebrew..."
  brew install starship
else
  echo "✅ Starship already installed"
fi

# --- Link Starship config ---
mkdir -p "$CONFIG_DIR"
ln -sf "$DOTFILES_DIR/.config/starship/starship.toml" "$STARSHIP_CONFIG"
echo "✅ Linked Starship config"

# --- Install Ghostty if not installed ---
if ! command -v ghostty &>/dev/null; then
  echo "⬇️  Installing Ghostty via Homebrew..."
  brew install ghostty
else
  echo "✅ Ghostty already installed"
fi

# --- Link Ghostty config ---
mkdir -p "$(dirname "$GHOSTTY_CONFIG")"
ln -sf "$DOTFILES_DIR/.config/ghostty/config" "$GHOSTTY_CONFIG"
echo "✅ Linked Ghostty config"

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

# Use shell inside container (zsh preferred, fallback to bash or sh)
devshell() {
  container=$(docker ps --filter "name=$1" --format "{{.Names}}" | head -n 1)
  if [ -z "$container" ]; then
    echo "❌ No container found matching: $1"
    return 1
  fi

  for shell in zsh bash sh; do
    if docker exec "$container" which "$shell" &>/dev/null; then
      docker exec -it "$container" "$shell"
      return
    fi
  done

  echo "❌ No compatible shell (zsh/bash/sh) found in container"
}

# Build/launch dev container in current folder
devbuild() {
  devcontainer up --workspace-folder "$PWD"
}
EOF

echo "✅ Created ~/.devaliases with devcontainer helpers"

# --- Download latest devcontainer helper ---
curl -fsSL https://raw.githubusercontent.com/kfuras/lab/main/bash/add-devcontainer.sh -o "$BIN_DIR/add-devcontainer"
chmod +x "$BIN_DIR/add-devcontainer"
echo "✅ Downloaded and prepared add-devcontainer.sh in ~/bin"

# --- Add local sourcing to shell config ---
for shell_rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  shell_name=$(basename "$shell_rc")
  shell_type="${shell_name#.}"  # Remove leading dot
  local_file="$DOTFILES_DIR/.${shell_type}.local"

  if [ -f "$shell_rc" ]; then
    if ! grep -qF "source \"$local_file\"" "$shell_rc"; then
      echo "" >> "$shell_rc"
      echo "# <<< dotfiles.local >>>" >> "$shell_rc"
      echo "[ -f \"$local_file\" ] && source \"$local_file\"" >> "$shell_rc"
      echo "# <<< dotfiles.local >>>" >> "$shell_rc"
      echo "✅ Updated ~/${shell_name} to source .${shell_type}.local"
    else
      echo "✅ ~/${shell_name} already sources .${shell_type}.local"
    fi
  fi
done

# --- Finish message with correct shell source suggestion ---
current_shell=$(basename "$SHELL")

case "$current_shell" in
  zsh)
    shell_rc_file="~/.zshrc"
    ;;
  bash)
    shell_rc_file="~/.bashrc"
    ;;
  *)
    shell_rc_file="your shell config file (unknown shell: $current_shell)"
    ;;
esac

echo "🎉 Bootstrap complete. Restart your shell or run: source $shell_rc_file"

