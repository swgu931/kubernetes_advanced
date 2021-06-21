#!/bin/bash


# Input NODE_TOKEN
# Input MASTER_IP

echo -n "please input NODE_TOKEN for joining cluter : "
read -s NODE_TOKEN

echo -n "please input MASTER_IP for joining cluter : "
read -s MASTER_IP

sudo apt update
sudo apt install -y docker.io nfs-common dnsutils curl


curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 \
K3S_TOKEN=$NODE_TOKEN \
INSTALL_K3S_EXEC="--node-name worker1 --docker" \
INSTALL_K3S_VERSION="v1.18.6+k3s1" sh -s --

