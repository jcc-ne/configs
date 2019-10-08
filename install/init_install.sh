#!/bin/sh

if [ $(uname|grep "Darwin") ];then
    PLATFORM="OSX"
elif [ $(uname|grep "Linux") ];then
    PLATFORM="LINUX"
else
    echo "Unknown Platform"
    exit 1
fi

echo "Current platform is: $PLATFORM"

echo "Install Anaconda..."

if [ $PLATFORM = "OSX" ];then
    echo "PLATFORM: $PLATFORM"    
elif [ $PLATFORM = "LINUX" ];then
   sudo add-apt-repository ppa:git-core/ppa
   sudo apt-get update
   sudo apt-get install git
fi
