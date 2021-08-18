#!/bin/bash

kubectl create ns monitoring
kubectl apply -f prometheus-cluster-role.yaml
kubectl apply -f prometheus-config-map.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-node-exporter.yaml
kubectl apply -f prometheus-svc.yaml

kubectl apply -f cluster-role-binding.yaml
#clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
kubectl apply -f cluster-role.yaml
#clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
kubectl apply -f deployment.yaml
#deployment.apps/kube-state-metrics created
kubectl apply -f service-account.yaml
#serviceaccount/kube-state-metrics created
kubectl apply -f service.yaml


wget https://github.com/prometheus/node_exporter/releases/download/v0.16.0-rc.1/node_exporter-0.16.0-rc.1.linux-amd64.tar.gz
tar -xzvf node_exporter-0.16.0-rc.1.linux-amd64.tar.gz
mv node_exporter-0.16.0-rc.1.linux-amd64 node_exporter

# =================================================================
# @master:/etc/systemd/system$ sudo nano node_exporter.service
# [sudo] k3s의 암호: 
# k3s@master:/etc/systemd/system$ 


# [Unit]
# Description=Node Exporter
# Wants=network-online.target
# After=network-online.target

# [Service]
# User=prometheus
# ExecStart=/home/admin/k8s/prometheus/server-node-exporter/node_exporter/node_exporter <-node_exporter가 설치된 디렉토리를 적는다

# [Install]
# WantedBy=default.target


# k3s@master:/etc/systemd/system$ systemctl status node_exporter
# ==================================================================



kubectl apply -f grafana-datasource-config.yaml
kubectl apply -f grafana-deployment.yaml
kubectl apply -f grafana-service.yaml
