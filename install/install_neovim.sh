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

uv venv ~/.venv/nvim --python 3.12
uv pip install --python ~/.venv/nvim neovim
cp $DIR/sitecustomize.py ~/.venv/nvim/lib/python3.12/site-packages/sitecustomize.py

mkdir -v -p ~/.config/nvim
ln -sf ~/.nvimrc ~/.config/nvim/init.vim

cd $my_cwd
