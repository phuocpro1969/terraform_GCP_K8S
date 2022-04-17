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

## output

```
make output
```

## restart

```
make restart
```

# How to use K8S

## dashboard

### check work in node

```
kubectl get po -n kubernetes-dashboard -o wide
```

### get password admin-user

```
export TOKEN_LOGIN=$(kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | awk '{print $2}' | tail -1)
echo $TOKEN_LOGIN
```

### url dashboard

```
https://<master1 or master2 IP address>:8001
```
