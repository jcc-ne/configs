#!/bin/sh

DIR=$(dirname $(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0))
my_cwd=$PWD

if [ ! $DIR = $PWD ]; then
   echo "need to execute the script from $DIR"
   echo "*** moving to working directory *** "
   echo
   cd $DIR
fi

cd ../my_patch/ohmyzsh_themes
mkdir -p ~/.oh-my-zsh/fav_themes
cp -r * ~/.oh-my-zsh/fav_themes

cd $mycwd
