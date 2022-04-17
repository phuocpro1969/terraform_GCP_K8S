#!/bin/bash
# install packages
sudo apt install snapd -y
sudo snap install jq
sudo apt install -y git wget  unzip

# install docker-compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

