#!/bin/bash

kubectl run nginx \
 --image=nginx \
 --replicas=1 \
 --requests=cpu=100m,memory=4Mi \
 --limits=cpu=200m,memory=8Mi \
 --namespace=ns
