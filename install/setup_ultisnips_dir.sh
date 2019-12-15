#! /bin/sh
#
# setup_ultisnips_dir.sh
# Copyright (C) 2019 janine <janine@Janines-iMac.local>
#
# Distributed under terms of the GNU GPLv3 license.
#


DIR=$(dirname $(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $0))
my_cwd=$PWD

if [ ! $DIR = $PWD ]; then
   echo "need to execute the script from $DIR"
   echo "*** moving to working directory *** "
   echo
   cd $DIR
fi

mkdir -p ~/.config/nvim/
ln -v -s $DIR/../my_patch/myBundle/UltiSnips ~/.config/nvim/

cd $my_cwd
