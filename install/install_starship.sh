#!/bin/sh
# Install Starship prompt and zoxide (replaces oh-my-zsh + p10k)

set -e

echo "Installing starship and zoxide via brew..."
brew install starship zoxide

echo ""
echo "Verifying installations:"
starship --version
zoxide --version

echo ""
echo "Done. Now run install/cp_dot_files.sh to symlink configs."
echo "Then restart your shell or run: exec zsh"
echo ""
echo "Optional: import existing z database into zoxide:"
echo "  zoxide import --from z ~/.z"
