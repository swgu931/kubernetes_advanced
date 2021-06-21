#!/bin/bash

sudo apt update
sudo apt install -y docker.io nfs-common dnsutils curl


curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
--disable traefik \
--disable metrics-server \
--node-name master --docker" \
INSTALL_K3S_VERSION="v1.18.6+k3s1" sh -s --

mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown -R $(id -u):$(id -g) ~/.kube
echo "export KUBECONFIG=~/.kube/config" >> ~/.bashrc
source ~/.bashrc

kubectl cluster-info

NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo "NODE_TOKEN="
echo $NODE_TOKEN

MASTER_IP=$(kubectl get node master -ojsonpath="{.status.addresses[0].address}")

echo "MASTER_IP="
echo $MASTER_IP