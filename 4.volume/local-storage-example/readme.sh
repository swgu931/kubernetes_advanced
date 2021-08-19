#!/bin/bash

# ref : https://lapee79.github.io/article/use-a-local-disk-by-local-volume-static-provisioner-in-kubernetes/

kubectl apply -f local-storage-class.yaml

## 이 명령어들을 POD가 생성될 worker node 상에서 실행합니다.
# mkdir -p /data/volumes/pv1
# chmode 777 /data/volumes/pv1

kubectl apply -f local-storage-pv.yaml
kubectl apply -f local-storage-pvc.yaml
kubectl apply -f local-storage-pvc-pod.yaml
