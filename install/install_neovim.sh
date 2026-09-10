#!/bin/sh

DIR=$(dirname $(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0))
my_cwd=$PWD

if [ ! $DIR = $PWD ]; then
   echo "need to execute the script from $DIR"
   echo "*** moving to working directory *** "
   echo
   cd $DIR
fi

. ./check_platform.sh

set -e

echo current PLATFORM: $(check_platform)

# tree-sitter-cli is required by nvim-treesitter's `main` branch to compile
# parsers (the python parser, used for foldexpr). Neovim 0.12 bundles
# c/lua/markdown/markdown_inline/query/vim/vimdoc already.
if [ $(check_platform) = "OSX" ];then
   brew install neovim tree-sitter-cli
elif [ $(check_platform) = "LINUX" ];then
   sudo apt install neovim
   cargo install tree-sitter-cli || echo "WARN: install tree-sitter-cli manually"
fi

# ~/.venv/nvim is the python *tooling* venv: it holds the language servers and
# their linters. It is no longer a pynvim host -- nvim needs no python3
# provider (see dot_nvimrc), but neovim_settings.lua resolves pylsp/ruff out
# of here when a project has no venv of its own.
uv venv ~/.venv/nvim --python 3.12
uv pip install --python ~/.venv/nvim \
   python-lsp-server \
   pylsp-mypy \
   python-lsp-ruff \
   pylint \
   mypy \
   ruff

# Lets pylsp/jedi see the active project's site-packages when the server is
# run from this venv rather than the project's own.
cp $DIR/sitecustomize.py ~/.venv/nvim/lib/python3.12/site-packages/sitecustomize.py

mkdir -v -p ~/.config/nvim
ln -sf ~/.nvimrc ~/.config/nvim/init.vim

cd $my_cwd
