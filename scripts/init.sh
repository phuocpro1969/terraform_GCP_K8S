#!/bin/bash

# disable firewall
sudo ufw disable

# disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# add password to root
sudo echo "ubuntu:root" | sudo chpasswd
sudo sed -i "s/^PermitRootLogin no/PermitRootLogin yes/" /etc/ssh/sshd_config
# sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo service sshd restart