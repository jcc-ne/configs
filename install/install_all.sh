#!/bin/sh
# Batch install script — sets up a fresh machine from the configs repo
# Usage: cd ~/configs/install && ./install_all.sh

set -e

DIR=$(dirname $(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0))
cd "$DIR"

. ./check_platform.sh
PLATFORM=$(check_platform)
echo "=== Platform: $PLATFORM ==="
echo ""

# --- Step 1: Symlink dotfiles ---
echo "=== Symlinking dotfiles ==="
./cp_dot_files.sh
echo ""

# --- Step 2: Prompts (starship + p10k + zoxide) ---
echo "=== Installing prompts ==="
./install_cmd_prompts.sh
echo ""

# --- Step 3: Neovim ---
echo "=== Installing neovim ==="
./install_neovim.sh
echo ""

# --- Step 4: Tmux plugin manager ---
echo "=== Installing tmux tpm ==="
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "  tpm already exists, skipping"
else
  ./install_tmux_tpm.sh
fi
echo ""

# --- Step 5: uv (Python package manager) ---
echo "=== Installing uv ==="
if command -v uv >/dev/null 2>&1; then
  echo "  uv already installed ($(uv --version)), skipping"
else
  if [ "$PLATFORM" = "OSX" ]; then
    brew install uv
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
fi
echo ""

echo "========================================="
echo "  All done! Restart your shell: exec zsh"
echo "========================================="
