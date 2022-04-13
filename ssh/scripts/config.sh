#!/bin/bash

# add config file
sudo /bin/su -c "cat >>/home/$1/.ssh/config<<EOF
Host github.com
IdentityFile /home/$1/.ssh/id_rsa

Host gitlab.com
IdentityFile /home/$1/.ssh/gitlab
EOF"

# set permissions
sudo chown $1 /home/$1/.ssh/config
sudo chown $1 /home/$1/.ssh/gitlab
sudo chown $1 /home/$1/.ssh/id_rsa
sudo chmod 600 /home/$1/.ssh/config
sudo chmod 600 /home/$1/.ssh/gitlab
sudo chmod 600 /home/$1/.ssh/id_rsa
