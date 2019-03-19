#!/bin/sh

echo "installing docker..."

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

apt-cache policy docker-ce
sudo apt-get install -y --allow-unauthenticated docker-ce

sudo systemctl status docker
sudo usermod -aG docker ${USER}
