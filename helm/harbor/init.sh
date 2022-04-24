#!/bin/bash

# add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

CURRENT_DIR=$HOME/helm/harbor
# array=(${EXTERNAL_IPS//,/ })

IFS=',' read -ra array <<< $EXTERNAL_IPS
sed "s/IPS/${array[1]}/" $CURRENT_DIR/temp.yaml > $CURRENT_DIR/config.yaml

# install
sed "s/_DOMAIN_/$1/ " $CURRENT_DIR/values.yaml | \
sed "s/_USERNAME_/$2/" | \
sed "s/_PASSWORD_/$3/" | \
sed "s/_LOAD_BALANCER_IP_/${array[1]}/" | \
helm install harbor bitnami/harbor -n harbor --create-namespace

# edit loadbalancer IP
kubectl patch svc -n harbor harbor --patch-file $CURRENT_DIR/config.yaml

# add host
echo "${array[1]} $1" >> /etc/hosts

# update domain docker
sed '0,/{/a \ \ "insecure-registries": [\n\t"'$1'"\n  ],' /etc/docker/daemon.json |& sudo tee -p /etc/docker/daemon.json

systemctl restart docker.service

# add host harbor and update domain docker
for ((i=2; i<=$MASTER_COUNT; i++))
do
ssh -o StrictHostKeyChecking=no "$USER@master$i" -i $HOME/.ssh/id_rsa.pri /bin/bash <<EOF
#!/bin/bash 
# add host
echo "${array[1]} $1" >> /etc/hosts

# update domain docker
sed '0,/{/a \ \ "insecure-registries": [\n\t"'$1'"\n  ],' /etc/docker/daemon.json |& sudo tee -p /etc/docker/daemon.json

systemctl restart docker.service

EOF
done

for ((i=1; i<=$WORKER_COUNT; i++))
do
# add host harbor 
ssh -o StrictHostKeyChecking=no "$USER@worker$i" -i $HOME/.ssh/id_rsa.pri /bin/bash <<EOF
#!/bin/bash 
# add host
echo "${array[1]} $1" >> /etc/hosts

# update domain docker
sed '0,/{/a \ \ "insecure-registries": [\n\t"'$1'"\n  ],' /etc/docker/daemon.json |& sudo tee -p /etc/docker/daemon.json

systemctl restart docker.service

EOF
done
