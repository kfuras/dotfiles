#!/bin/bash

set -e

# --- Constants ---
DOTFILES_DIR="$HOME/code/dotfiles"
BIN_DIR="$HOME/bin"
DEVALIASES="$HOME/.devaliases"
STARSHIP_CONFIG="$DOTFILES_DIR/.config/starship/starship.toml"
GHOSTTY_CONFIG="$DOTFILES_DIR/.config/ghostty/config"

# --- Start Setup ---
echo "🔧 Setting up dotfiles environment..."

# --- Ensure ~/bin directory exists ---
mkdir -p "$BIN_DIR"

# --- Install Starship if missing ---
if ! command -v starship &>/dev/null; then
  echo "⬇️  Installing Starship via Homebrew..."
  brew install starship
else
  echo "✅ Starship already installed"
fi

# --- Link Starship config ---
mkdir -p "$HOME/.config"
ln -sf "$STARSHIP_CONFIG" "$HOME/.config/starship.toml"
echo "✅ Linked Starship config"

# --- Install Ghostty if missing ---
if ! command -v ghostty &>/dev/null; then
  echo "⬇️  Installing Ghostty via Homebrew..."
  brew install ghostty
else
  echo "✅ Ghostty already installed"
fi

# --- Link Ghostty config ---
mkdir -p "$HOME/.config/ghostty"
ln -sf "$GHOSTTY_CONFIG" "$HOME/.config/ghostty/config"
echo "✅ Linked Ghostty config"

# --- Create ~/.devaliases ---
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
  if docker exec "$container" command -v zsh &>/dev/null; then
    docker exec -it "$container" zsh
  else
    docker exec -it "$container" sh
  fi
}

devbuild() {
  devcontainer up --workspace-folder "$PWD"
}
EOF

echo "✅ Created ~/.devaliases with devcontainer helpers"

# --- Download helper script ---
curl -fsSL https://raw.githubusercontent.com/kfuras/lab/main/bash/add-devcontainer.sh -o "$BIN_DIR/add-devcontainer"
chmod +x "$BIN_DIR/add-devcontainer"
echo "✅ Downloaded and prepared add-devcontainer.sh in ~/bin"

# --- Add local sourcing to shell config ---
for shell_rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  shell_name=$(basename "$shell_rc")
  shell_type="${shell_name#.}"
  local_file="$DOTFILES_DIR/.${shell_type}.local"

  if [ -f "$shell_rc" ]; then
    if ! grep -qF "source \"$local_file\"" "$shell_rc"; then
      {
        echo ""
        echo "# <<< dotfiles.local >>>"
        echo "[ -f \"$local_file\" ] && source \"$local_file\""
        echo "# <<< dotfiles.local >>>"
      } >> "$shell_rc"
      echo "✅ Updated ~/${shell_name} to source .${shell_type}.local"
    else
      echo "✅ ~/${shell_name} already sources .${shell_type}.local"
    fi
  fi

done

# --- Final success message with current shell ---
current_shell="$(basename "$SHELL")"
case "$current_shell" in
  zsh)   shell_file="~/.zshrc" ;;
  bash)  shell_file="~/.bashrc" ;;
  *)     shell_file="your shell config file" ;;
esac

echo "✨ Bootstrap complete. Restart your shell or run: source $shell_file"

