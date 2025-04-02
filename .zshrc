# Load Zsh plugins manually
# Ensure these are installed via Homebrew (or manually in ~/.zsh)
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /opt/homebrew/share/zsh-completions/zsh-completions.zsh ]; then
  source /opt/homebrew/share/zsh-completions/zsh-completions.zsh
fi

# Ensure correct completion init
autoload -Uz compinit
compinit

# Use Starship for prompt
eval "$(starship init zsh)"

# <<< dotfiles >>>
[ -f ~/.devaliases ] && source ~/.devaliases
