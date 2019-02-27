#!/bin/sh

check_platform() {
    if [ $(uname|grep "Darwin") ];then
        PLATFORM="OSX"
    elif [ $(uname|grep "Linux") ];then
        PLATFORM="LINUX"
    else
        echo "Unknown Platform"
        exit 1
    fi
    echo "$PLATFORM"
}

export check_platform
