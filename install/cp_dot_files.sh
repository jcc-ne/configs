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

ln dot_tmux.conf ~/.tmux.conf
ln dot_zshrc ~/.zshrc
ln dot_vimrc ~/.vimrc
ln dot_nvimrc ~/.nvimrc

cd $my_cwd
