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
   echo "not supported on a Mac"
elif [ $(check_platform) = "LINUX" ];then
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
          sudo tee /etc/apt/sources.list.d/nvidia-docker.list

   sudo apt-get update
   
   # Install nvidia-docker2 and reload the Docker daemon configuration
   sudo apt-get install -y nvidia-docker2
   sudo pkill -SIGHUP dockerd

   # Test run
   docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
fi

cd $my_cwd
