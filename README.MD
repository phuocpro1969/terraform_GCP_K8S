<center><h1>TUTORIAL</h1></center>

# HOW TO USE

## init beginning terraform

```
make init
```

## deploy

```
make apply
```

## check plan

```
make plan
```

## destroy

```
make destroy
```

# How to use K8S

## dashboard

### check work in node

```
kubectl get po -n kubernetes-dashboard -o wide
```

### get password admin-user

```
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

```

### url dashboard

```
http://<master1 or master2 IP address>:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```
