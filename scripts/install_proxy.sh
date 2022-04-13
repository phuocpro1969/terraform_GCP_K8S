#!/bin/bash

# install haproxy
sudo apt update -y 
sudo apt install -y haproxy

sudo /bin/su -c "cat >>/etc/haproxy/haproxy.cfg<<EOF

frontend kubernetes-frontend
    bind 10.20.0.10:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server master1 10.20.0.11:6443 check fall 3 rise 2
    server master2 10.20.0.12:6443 check fall 3 rise 2
EOF"

sudo service haproxy restart
sudo apt update -y