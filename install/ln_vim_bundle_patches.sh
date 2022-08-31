#!/bin/sh


DIR=$(dirname $(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0))
my_cwd=$PWD

if [ ! $DIR = $PWD ]; then
   echo "need to execute the script from $DIR"
   echo "*** moving to working directory *** "
   echo
   cd $DIR
fi

cd ~/.vim/bundle

ln -s $DIR/../my_patch/myBundle || true

mkdir -v -p ~/.config/nvim/lua
cd ~/.config/nvim/lua
ln -s $DIR/../dot_files/plugins.lua .

cd $my_cwd
