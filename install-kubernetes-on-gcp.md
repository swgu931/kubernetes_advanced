# Install kubernates on Google Cloud Platform
## Part5. Ch2. 10~11
- ref: https://github.com/Jaesang/fastcampus_kubernetes

## Setup VPC, Firewall, IP, Router
```
gcloud init
gcloud config list
gcloud compute networks create fastcampus-k8s --subnet-mode custom
gcloud compute networks subnets create k8s-nodes \
 --network fastcampus-k8s \
 --range 10.240.0.0/24 

gcloud compute firewall-rules create fastcampus-k8s-allow-internal \
 --allow tcp, udp, icmp, ipip \
 --network fastcampus-k8s \
 --source-ranges 10.240.0.0./24

gcloud compute firewall-rules create fastcampus-k8s-allow-external \
 --allow tcp:22, tcp:6443, icmp \
 --network fastcampus-k8s \
 --source-range 0.0.0.0/0

gcloud compute addresses list
gcloud compute addresses create fascampus-k8s  # 외부IP설정


gcloud compute routers create k8s-router \
 --network fastcampus-k8s \
 --region asia-northeast3

gcloud compute routers nats create k8s-nat \
 --router-region asia-northeast3 \
 --router k8s-router \
 --nat-all-subnet-ip-ranges \
 --auto-allocate-nat-external-ips
 ```
 
===============================
## Setup Master Node

```
for i in 0 1 2: do
gcloud compute instances create controller-${i} \
--async \
--boot-disk-size 200GB \
--can-ip-forward \
--image-family ubuntu-2004-lts \
--image-project ubuntu-os-cloud \
--machine-type e2-standard-2 \
--private-network-ip 10.240.0.1${i} \
--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
--subnet k8s-nodes \
--tags fastcampus-k8s,controller

gcloud compute instances list
```
### controller-0, 1, 2 setup 

```
#controller-0, 1, 2  에 ssh에 접속

gcloud compute ssh controller-0
gcloud compute ssh controller-1
gcloud compute ssh controller-2
```
#### controller-0, 1, 2 에 kubectl, kubelet, kubeadm, containerd 설치
```
sudo apt update
sudo apt -y install apt-transport-https 
curl -s https://packages.cloud.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubectl version --client && kubeadm version

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io

sudo su -
mkdir -p /etc/containerd
containerd config defaults>/etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

vi /etc/containerd/config.toml
---
SystemCgroup = true
---

sudo systemctl restart containerd
sudo systemctl statuscontainerd
sudo systemctl enable kubelet
sudo systemctl sart kubelet
sudo systemctl status kubelet
sudo systemctl stop kubelet

cat << EOF | sudo tee /etc/kubernetes/cloud-config
[Global]
project-id = my-project-for-demo-346601
EOF
```

### LoadBalancer setup
```
gloud compute firewall-rules create fw-allow-network-lb-health-check \
--network=fastcampus-k8s \
--action=ALLOW \
--direction=INGRESS \
--source-ranges=35.191.0.0/16,209.85.152.0/22,209.85.204.0/22 \
--target-tags=allow-network-lb-health-checks \
--rules=tcps=controller-0

# loadbalancer 에 controller node 를 등록
gcloud compute instance-grpoups unmanaged create k8s-master \
--zone=asia-northeast3-a

gcloud compute instance-groups unmanaged add-instances k8s-master \
--zone=asia-northeast3-a \
--instances=controller-0

gcloud compute health-checks create https k8s-controller-hc --check-interval=5 \
--enable-logging \
--request-path=/healthz \
--port=6443 \
--region=asia-northeast3

gcloud compute backend-services create k8s-service \
--protocol TCP \
--health-checks k8s-controller-hc \
--health-checks-region asia-northeast3 \
--region asia-northeast3

gcloud compute backend-service add-backend k8s-service \
--instance-group k8s-master \
--instance-group-zone asia-northeast3-a \
--region asia-northeast3

gcloud compute forwarding-rules create k8s-forwarding-rule \
--load-balancing-scheme external \
--region asia-northeast3 \
--ports 6443 \
--address fastcampus-k8s \
--backend-service k8s-service
```
```
gcloud compute addresses list
```
 
### controller-0 에 kubeadm, kubeconfig setup
```
gcloud compute ssh controller-0
```
```
cat << EOF > kubeadmcfg.yaml
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  criSocket: "/run/containerd/containerd.sock"
  kubeletExtraArgs:
    cloud-provider: "gce"
    cloud-config; "/etc/kubernetes/cloud-config"
    cgroup-driver: "systemd"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  extraARgs:
    cloud-provider: "gce"
    cloud-config: "/etc/kubernetes/cloud-config"
  extraVolumes:
  - name: cloud
    hostPath: "/etc/kubernetes/cloud-config"
    mountPath: "/etc/kubernetes/cloud-config"
controllerManager:
  extraArgs:
    cloud-provider: "gce"
    cloud-config: "/etc/kubernetes/cloud-config"
  extraVolumes:
  - name: cloud
    hostPath: "/etc/kubernetes/cloud-config"
    mountPath: "/etc/kubernetes/cloud-config"
networking:
  podSubnet: "192.168.0.0/16"
  serviceSubnet: "10.32.0.0/24"
controlPlaneEndpoint: "34.64.244.64:6443"    #   appeared by gcloud compute addresses list
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
serverTLSBootstrap: true
EOF

sudo kubeadm init --upload-certs --config kubeadmcfg.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
```

### controller-1, 2 에서 kubeadm control-plane 으로 join
```
gcloud compute ssh controller-1
gcloud compute ssh controller-2
```
```
sudo kubeadm join 34.64.244.64:6443 --token xlxllslskdljflsdjlff \
--discovery-token-ca-cert-hash sha256:64lskdjlfsldjlkf02030-30--0-4ldsjlkfsldj \
--control-plane --certificate-key e7s03090439o0sdjfs0d9f0sd0f0s8d90f908d
```

```
# controller -0 에서 kubectl get nodes 로 확인 
```

## Setup Worker Node

### GCP에 instance 생성
```
for i in 0 1 2: do
gcloud compute instances create worker-${i} \
--async \
--boot-disk-size 200GB \
--can-ip-forward \
--image-family ubuntu-2004-lts \
--image-project ubuntu-os-cloud \
--machine-type e2-standard-2 \
--metadata pod-cidr=10.200.${i}.0/24 \
--private-network-ip 10.240.0.1${i} \
--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
--subnet k8s-nodes \
--tags fastcampus-k8s,worker

gcloud compute instances list
```
### worker node에 접속 및 kubectl, kubeadm, kubelet, containerd 설치
```
gloud compute ssh worker-0
gloud compute ssh worker-1
gloud compute ssh worker-2
```
```
sudo apt update
sudo apt -y install apt-transport-https 
curl -s https://packages.cloud.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubectl version --client && kubeadm version

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io
sudo systemctl status containerd

sudo su -
mkdir -p /etc/containerd
containerd config defaults>/etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

vi /etc/containerd/config.toml
---
SystemCgroup = true
---

sudo systemctl restart containerd
sudo systemctl statuscontainerd
sudo systemctl enable kubelet
sudo systemctl sart kubelet
sudo systemctl status kubelet
sudo systemctl stop kubelet

cat << EOF | sudo tee /etc/kubernetes/cloud-config
[Global]
project-id = my-project-for-demo-346601
EOF
```
### worker-0, 1, 2 를 worker node 로 join 시킴
```
kubeadm join 34.64.244.64:6443 --token 9s9393xvd898df0s8d0f8 \
--discovery-token-ca-cert-hash sha256:987d9fg79df6g8fd67868g6d87f6g8d6f8g
```

### 서명된 kubelet 인증서를 활성화함
```
kubectl get csr
```

#### Approve 
```
kubectl get csr | grep Pending | awk '{print "kubectl certifcate approve "$1}'
kubectl get csr | grep Pending | awk '{print "kubectl certifcate approve "$1}' | bash
```
# End

