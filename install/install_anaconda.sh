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

if [ $(check_platform) = "OSX" ];then
    wget https://repo.anaconda.com/archive/Anaconda3-2018.12-MacOSX-x86_64.sh
    bash Anaconda3-2018.12-MacOSX-x86_64.sh -b
elif [ $(check_platform) = "LINUX" ];then
    wget https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
    bash Anaconda3-2018.12-Linux-x86_64.sh -b
fi

cd $my_cwd
