#!/bin/bash

# install haproxy
sudo apt update -y
sudo apt install -y haproxy

sudo tee -a /etc/haproxy/haproxy.cfg <<-EOF
frontend kubernetes-frontend
    bind 10.20.0.10:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
EOF

for ((i=1; i<=$MASTER_COUNT; i++))
do
sudo tee -a /etc/haproxy/haproxy.cfg <<-EOF
    server master$i 10.20.0.1$i:6443 check fall 3 rise 2
EOF
done

sudo service haproxy restart
