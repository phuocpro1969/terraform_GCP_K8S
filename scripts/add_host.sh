#!/bin/bash

# add hosts lb
sudo tee -a /etc/hosts <<-EOF
10.20.0.10 loadbalancer.google.internal lb
EOF

# add hosts master
for ((i=1; i<=$MASTER_COUNT; i++))
do
sudo tee -a /etc/hosts <<-EOF
10.20.0.1${i} master${i}.google.internal master${i}
EOF
done

# add hosts worker
for ((i=1; i<=$WORKER_COUNT; i++))
do
sudo tee -a /etc/hosts <<-EOF
10.20.0.2${i} worker${i}.google.internal worker${i}
EOF
done
