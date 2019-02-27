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

if [ $PLATFORM == "OSX" ];then
    
elif [ $PLATFORM == "LINUX" ];then

fi
