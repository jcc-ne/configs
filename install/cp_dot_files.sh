#!/bin/sh

DIR=$(dirname $(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0))
my_cwd=$PWD

if [ ! $DIR = $PWD ]; then
   echo "need to execute the script from $DIR"
   echo "*** moving to working directory *** "
   echo
   cd $DIR
fi

cd ../dot_files

ln -sv $PWD/dot_tmux.conf ~/.tmux.conf
ln -sv $PWD/dot_zshrc ~/.zshrc
ln -sv $PWD/dot_vimrc ~/.vimrc
ln -sv $PWD/dot_nvimrc ~/.nvimrc
ln -sv $PWD/dot_gitconfig ~/.gitconfig

cd $my_cwd
