# etcd operator 

```
git clone https://github.com/coreos/etcd-operator
etcd-operator/example/rbac/create_role.sh
```
```
vi etcd-operator/example/deployment.yaml

---
  selector:
    matchLabels:
      name: etcd-operator
  replicas: 3
  template:
    metadata:
---
```

```
kubectl create -f deployment.yaml

kubectl create -f example-etcd-cluster.yaml 

kubectl get pods -o wide | grep etcd-cluster

kubectl get customresourcedefinitions

kubectl exec example-etcd-cluster-74xvlgwkz9 etcdctl cluster-health

kubectl exec example-etcd-cluster-74xvlgwkz9 etcdctl set test "Hello etcd~"
kubectl exec example-etcd-cluster-74xvlgwkz9 etcdctl get test
```


## scale out
```
vi example-etcd-cluster.yaml
...
size: 3  ==> 5
...
```
```
kubectl get pods -o wide | grep etcd-cluster
```