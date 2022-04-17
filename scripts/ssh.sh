#!/bin/bash

# set permissions
chown $(whoami) $HOME/.ssh/*
chmod 600 $HOME/.ssh/config
chmod 600 $HOME/.ssh/*.pri

# add config file
sudo tee -a $HOME/.ssh/config <<-EOF
Host github.com
IdentityFile $HOME/.ssh/id_rsa.pri

Host gitlab.com
IdentityFile $HOME/.ssh/gitlab.pri
EOF
