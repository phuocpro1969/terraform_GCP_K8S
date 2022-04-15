#!/bin/bash

# add hosts
sudo /bin/su -c "cat >>/etc/hosts<<EOF
10.20.0.10 loadbalancer.google.internal lb
EOF"

for ((i=1; i<=$1; i++))
do

sudo /bin/su -c "cat >>/etc/hosts<<EOF
10.20.0.1${i} master${i}.google.internal master${i}
EOF"

done

for ((i=2; i<=$2; i++))
do

sudo /bin/su -c "cat >>/etc/hosts<<EOF
10.20.0.1${i} master${i}.google.internal master${i}
EOF"

done