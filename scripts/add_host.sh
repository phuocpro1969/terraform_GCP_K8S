#!/bin/bash

# add hosts and hostname
sudo /bin/su -c "cat >>/etc/hosts<<EOF
10.20.0.10 loadbalancer.google.internal lb
EOF"

sudo /bin/su -c "cat >>/etc/hostname<<EOF
lb
EOF"

for i in {1..$1}
do

sudo /bin/su -c "cat >>/etc/hosts<<EOF
10.20.0.1${i} master${i}.google.internal master${i}
EOF"

sudo /bin/su -c "cat >>/etc/hostname<<EOF
master${i}
EOF"

done

for i in {1..$2}
do

sudo /bin/su -c "cat >>/etc/hosts<<EOF
10.20.0.1${i} master${i}.google.internal master${i}
EOF"

sudo /bin/su -c "cat >>/etc/hostname<<EOF
worker${i}
EOF"

done