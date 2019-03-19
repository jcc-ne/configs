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
   # Add NVIDIA package repositories
   # Add HTTPS support for apt-key
   sudo apt-get install gnupg-curl
   wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_10.0.130-1_amd64.deb
   sudo dpkg -i cuda-repo-ubuntu1604_10.0.130-1_amd64.deb
   sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
   sudo apt-get update
   wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb
   sudo apt install ./nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb
   sudo apt-get update

   # Install NVIDIA Driver
   # Issue with driver install requires creating /usr/lib/nvidia
   sudo mkdir /usr/lib/nvidia
   sudo apt-get install --no-install-recommends nvidia-410
   # Reboot. Check that GPUs are visible using the command: nvidia-smi

   # Install development and runtime libraries (~4GB)
   sudo apt-get install --no-install-recommends \
	  cuda-10-0 \
	  libcudnn7=7.4.1.5-1+cuda10.0  \
	  libcudnn7-dev=7.4.1.5-1+cuda10.0


   # Install TensorRT. Requires that libcudnn7 is installed above.
   sudo apt-get update && \
	  sudo apt-get install nvinfer-runtime-trt-repo-ubuntu1604-5.0.2-ga-cuda10.0 \
	  && sudo apt-get update \
	  && sudo apt-get install -y --no-install-recommends libnvinfer-dev=5.0.2-1+cuda10.0

fi

cd $my_cwd
