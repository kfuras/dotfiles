#!/bin/bash

cd ~/dotfiles || exit 1

if [[ "$SHELL" =~ "zsh" ]]; then
  ln -sf ~/dotfiles/.zshrc ~/.zshrc
  echo "Linked .zshrc"
elif [[ "$SHELL" =~ "bash" ]]; then
  ln -sf ~/dotfiles/.bashrc ~/.bashrc
  ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
  echo "Linked .bashrc and .bash_aliases"
fi

mkdir -p ~/.config
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml

exec "$SHELL"
