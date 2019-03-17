#!/bin/sh

if [ -z $1 ];then
    echo "Usage: ./add_sudoers.sh <username>"
    exit 1
fi

echo "add sudoer: $1"

sudo adduser $1
sudo usermod -aG sudo $1
