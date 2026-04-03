#!/bin/sh
# Install prompts: starship + powerlevel10k (standalone) + zoxide

set -e

echo "Installing starship and zoxide via brew..."
brew install starship zoxide

echo ""
echo "Cloning powerlevel10k..."
if [ -d "$HOME/.config/powerlevel10k" ]; then
  echo "  powerlevel10k already exists, pulling latest..."
  git -C "$HOME/.config/powerlevel10k" pull
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.config/powerlevel10k"
fi

echo ""
echo "Verifying installations:"
starship --version
zoxide --version
echo "powerlevel10k: $(ls "$HOME/.config/powerlevel10k/powerlevel10k.zsh-theme" && echo OK)"

echo ""
echo "Done. Run install/cp_dot_files.sh to symlink configs, then: exec zsh"
