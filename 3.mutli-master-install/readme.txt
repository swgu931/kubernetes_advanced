##### 마스터1
k3s@master:~/바탕화면$ cat /etc/hostname
master1.example.com
k3s@master:~/바탕화면$ cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	k3s-VirtualBox

10.0.2.100	master1.example.com	master1
10.0.2.101	m1-worker1.example.com	m1-worker1


10.0.2.200	master2.example.com	master2
10.0.2.201	m2-worker1.example.com	m2-worker1
# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
k3s@master:~/바탕화면$ 


k3s@master:~/바탕화면$ /usr/local/bin/k3s-uninstall.sh
+ id -u
+ [ 1000 -eq 0 ]
+ exec sudo /usr/local/bin/k3s-uninstall.sh
+ id -u
+ [ 0 -eq 0 ]
+ /usr/local/bin/k3s-killall.sh
+ [ -s /etc/systemd/system/k3s.service ]
+ basename /etc/systemd/system/k3s.service
+ systemctl stop k3s.service
+ [ -x /etc/init.d/k3s* ]
+ killtree
+ kill -9
+ do_unmount_and_remove /run/k3s
+ awk -v path=/run/k3s $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ sort -r
+ do_unmount_and_remove /var/lib/rancher/k3s
+ awk -v path=/var/lib/rancher/k3s $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ sort -r
+ do_unmount_and_remove /var/lib/kubelet/pods
+ sort -r
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ awk -v path=/var/lib/kubelet/pods $2 ~ ("^" path) { print $2 } /proc/self/mounts
sh -c 'umount "$0" && rm -rf "$0"' /var/lib/kubelet/pods/bc00e87d-0fe1-4dc3-bbc7-41f393db1812/volumes/kubernetes.io~secret/coredns-token-h5p86 
sh -c 'umount "$0" && rm -rf "$0"' /var/lib/kubelet/pods/7fbc988b-f370-495a-9aa1-d15384ae7ee4/volumes/kubernetes.io~secret/local-path-provisioner-service-account-token-k2qlf 
+ do_unmount_and_remove /var/lib/kubelet/plugins
+ awk -v path=/var/lib/kubelet/plugins $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ sort -r
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ do_unmount_and_remove /run/netns/cni-
+ sort -r
+ awk -v path=/run/netns/cni- $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ + xargs -r -t -n 1 ip netns delete
ip netns show
+ grep cni-
+ ip link show
+ read ignore iface ignore
+ grep master cni0
+ iface=vetha910f4e3
+ [ -z vetha910f4e3 ]
+ ip link delete vetha910f4e3
+ read ignore iface ignore
+ iface=vethccd1e5c7
+ [ -z vethccd1e5c7 ]
+ ip link delete vethccd1e5c7
+ read ignore iface ignore
+ ip link delete cni0
+ ip link delete flannel.1
+ rm -rf /var/lib/cni/
+ iptables-save
+ grep -v CNI-
+ iptables-restore
+ grep -v KUBE-
+ command -v systemctl
/usr/bin/systemctl
+ systemctl disable k3s
Removed /etc/systemd/system/multi-user.target.wants/k3s.service.
+ systemctl reset-failed k3s
+ systemctl daemon-reload
+ command -v rc-update
+ rm -f /etc/systemd/system/k3s.service
+ rm -f /etc/systemd/system/k3s.service.env
+ trap remove_uninstall EXIT
+ [ -L /usr/local/bin/kubectl ]
+ rm -f /usr/local/bin/kubectl
+ [ -L /usr/local/bin/crictl ]
+ rm -f /usr/local/bin/crictl
+ [ -L /usr/local/bin/ctr ]
+ rm -rf /etc/rancher/k3s
+ rm -rf /run/k3s
+ rm -rf /run/flannel
+ rm -rf /var/lib/rancher/k3s
+ rm -rf /var/lib/kubelet
+ rm -f /usr/local/bin/k3s
+ rm -f /usr/local/bin/k3s-killall.sh
+ type yum
+ remove_uninstall
+ rm -f /usr/local/bin/k3s-uninstall.sh

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=" \
server --cluster-init \
--disable traefik \
--disable metrics-server \
--node-name master1 --docker" \
INSTALL_K3S_VERSION="v1.20.0-rc4+k3s1" sh -s –



k3s@master:~/바탕화면$ curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=" \
> server --cluster-init \
> --disable traefik \
> --disable metrics-server \
> --node-name master1 --docker" \
> INSTALL_K3S_VERSION="v1.20.0-rc4+k3s1" sh -s –
[INFO]  Using v1.20.0-rc4+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.20.0-rc4+k3s1/sha256sum-amd64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.20.0-rc4+k3s1/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Skipping /usr/local/bin/ctr symlink to k3s, command exists in PATH at /usr/bin/ctr
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
k3s@master:~/바탕화면$ sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
k3s@master:~/바탕화면$ sudo chown -R k3s:k3s .kube
chown: '.kube'에 접근할 수 없습니다: 그런 파일이나 디렉터리가 없습니다
k3s@master:~/바탕화면$ sudo chown -R k3s:k3s ~/.kube
k3s@master:~/바탕화면$ sudo cat /var/lib/rancher/k3s/server/node-token
K10f8ea94056f82306e11b766b434877a99373d5822a2540a4e331d5ad6680e7f9d::server:3506a2678e5964eb9eb08defaf7a0353


[마스터1-워크노드1 추가]
/usr/local/bin/k3s-agent-uninstall.sh
NODE_TOKEN=K10f8ea94056f82306e11b766b434877a99373d5822a2540a4e331d5ad6680e7f9d::server:3506a2678e5964eb9eb08defaf7a0353
MASTER_IP=10.0.2.100

curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 \
K3S_TOKEN=$NODE_TOKEN \
INSTALL_K3S_EXEC="--node-name m1-worker1 --docker" \
INSTALL_K3S_VERSION="v1.20.0-rc4+k3s1" sh -s –



mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown -R $(id -u):$(id -g) ~/.kube



##### 마스터2

k3s@master2:~/바탕화면$ /usr/local/bin/k3s-uninstall.sh
+ id -u
+ [ 1000 -eq 0 ]
+ exec sudo /usr/local/bin/k3s-uninstall.sh
sudo: master2.example.com 호스트를 해석할 수 없습니다: name resolution에서 일시적인 실패
[sudo] k3s의 암호: 
+ id -u
+ [ 0 -eq 0 ]
+ /usr/local/bin/k3s-killall.sh
+ [ -s /etc/systemd/system/k3s.service ]
+ basename /etc/systemd/system/k3s.service
+ systemctl stop k3s.service
+ [ -x /etc/init.d/k3s* ]
+ killtree
+ kill -9
+ do_unmount_and_remove /run/k3s
+ awk -v path=/run/k3s $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ sort -r
+ do_unmount_and_remove /var/lib/rancher/k3s
+ awk -v path=/var/lib/rancher/k3s $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ sort -r
+ do_unmount_and_remove /var/lib/kubelet/pods
+ awk -v path=/var/lib/kubelet/pods $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ + xargssort -r -t -n -r 1
 sh -c umount "$0" && rm -rf "$0"
sh -c 'umount "$0" && rm -rf "$0"' /var/lib/kubelet/pods/bc00e87d-0fe1-4dc3-bbc7-41f393db1812/volumes/kubernetes.io~secret/coredns-token-h5p86 
sh -c 'umount "$0" && rm -rf "$0"' /var/lib/kubelet/pods/7fbc988b-f370-495a-9aa1-d15384ae7ee4/volumes/kubernetes.io~secret/local-path-provisioner-service-account-token-k2qlf 
+ do_unmount_and_remove /var/lib/kubelet/plugins
+ sort -r
+ awk -v path=/var/lib/kubelet/plugins $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ do_unmount_and_remove /run/netns/cni-
+ sort -r
+ awk -v path=/run/netns/cni- $2 ~ ("^" path) { print $2 } /proc/self/mounts
+ xargs -r -t -n 1 sh -c umount "$0" && rm -rf "$0"
+ ip netns show
+ xargs -r -t -n 1 ip netns delete
+ grep cni-
+ ip link show
+ read ignore iface ignore
+ grep master cni0
+ iface=veth94cda338
+ [ -z veth94cda338 ]
+ ip link delete veth94cda338
+ read ignore iface ignore
+ iface=vethe8c89907
+ [ -z vethe8c89907 ]
+ ip link delete vethe8c89907
+ read ignore iface ignore
+ ip link delete cni0
+ ip link delete flannel.1
+ rm -rf /var/lib/cni/
+ iptables-save
+ grep -v KUBE-
+ grep -v CNI-
+ iptables-restore
+ command -v systemctl
/usr/bin/systemctl
+ systemctl disable k3s
Removed /etc/systemd/system/multi-user.target.wants/k3s.service.
+ systemctl reset-failed k3s
+ systemctl daemon-reload
+ command -v rc-update
+ rm -f /etc/systemd/system/k3s.service
+ rm -f /etc/systemd/system/k3s.service.env
+ trap remove_uninstall EXIT
+ [ -L /usr/local/bin/kubectl ]
+ rm -f /usr/local/bin/kubectl
+ [ -L /usr/local/bin/crictl ]
+ rm -f /usr/local/bin/crictl
+ [ -L /usr/local/bin/ctr ]
+ rm -rf /etc/rancher/k3s
+ rm -rf /run/k3s
+ rm -rf /run/flannel
+ rm -rf /var/lib/rancher/k3s
+ rm -rf /var/lib/kubelet
+ rm -f /usr/local/bin/k3s
+ rm -f /usr/local/bin/k3s-killall.sh
+ type yum
+ remove_uninstall
+ rm -f /usr/local/bin/k3s-uninstall.sh
k3s@master2:~/바탕화면$ NODE_TOKEN=K10f8ea94056f82306e11b766b434877a99373d5822a2540a4e331d5ad6680e7f9d::server:3506a2678e5964eb9eb08defaf7a0353
k3s@master2:~/바탕화면$ MASTER_IP=10.0.2.100
k3s@master2:~/바탕화면$ curl -sfL https://get.k3s.io | K3S_TOKEN=$NODE_TOKEN \
> INSTALL_K3S_EXEC=" \
> server --server https://$MASTER_IP:6443 \
> --disable traefik \
> --disable metrics-server \
> --node-name master2 --docker" \
> INSTALL_K3S_VERSION="v1.20.0-rc4+k3s1" sh -s –
sudo: master2.example.com 호스트를 해석할 수 없습니다: name resolution에서 일시적인 실패
^X
^C
k3s@master2:~/바탕화면$ 
k3s@master2:~/바탕화면$ sudo nano /etc/hosts
sudo: master2.example.com 호스트를 해석할 수 없습니다: name resolution에서 일시적인 실패
k3s@master2:~/바탕화면$ curl -sfL https://get.k3s.io | K3S_TOKEN=$NODE_TOKEN \
> INSTALL_K3S_EXEC=" \
> server --server https://$MASTER_IP:6443 \
> --disable traefik \
> --disable metrics-server \
> --node-name master2 --docker" \
> INSTALL_K3S_VERSION="v1.20.0-rc4+k3s1" sh -s –
[INFO]  Using v1.20.0-rc4+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.20.0-rc4+k3s1/sha256sum-amd64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.20.0-rc4+k3s1/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Skipping /usr/local/bin/ctr symlink to k3s, command exists in PATH at /usr/bin/ctr
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
k3s@master2:~/바탕화면$ sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
k3s@master2:~/바탕화면$ sudo chown -R k3s:k3s ~/.kube
k3s@master2:~/바탕화면$ sudo cat /var/lib/rancher/k3s/server/node-token
K10f8ea94056f82306e11b766b434877a99373d5822a2540a4e331d5ad6680e7f9d::server:3506a2678e5964eb9eb08defaf7a0353
k3s@master2:~/바탕화면$

[마스터2-워크노드1 추가]
/usr/local/bin/k3s-agent-uninstall.sh
NODE_TOKEN=K10f8ea94056f82306e11b766b434877a99373d5822a2540a4e331d5ad6680e7f9d::server:3506a2678e5964eb9eb08defaf7a0353
MASTER2_IP=10.0.2.200

curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER2_IP:6443 \
K3S_TOKEN=$NODE_TOKEN \
INSTALL_K3S_EXEC="--node-name m2-worker1 --docker" \
INSTALL_K3S_VERSION="v1.20.0-rc4+k3s1" sh -s –




##### 확인
마스터 1과 마스터 2에서 모두 조회가 가능
k3s@master1:~/바탕화면$ kubectl get node -owide
NAME         STATUS   ROLES                       AGE    VERSION            INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
m1-worker1   Ready    <none>                      6m3s   v1.20.0-rc4+k3s1   10.0.2.101    <none>        Ubuntu 20.04.2 LTS   5.8.0-55-generic   docker://20.10.2
m2-worker1   Ready    <none>                      85s    v1.20.0-rc4+k3s1   10.0.2.201    <none>        Ubuntu 20.04.2 LTS   5.8.0-55-generic   docker://20.10.2
master1      Ready    control-plane,etcd,master   53m    v1.20.0-rc4+k3s1   10.0.2.100    <none>        Ubuntu 20.04.2 LTS   5.8.0-55-generic   docker://20.10.2
master2      Ready    control-plane,etcd,master   31m    v1.20.0-rc4+k3s1   10.0.2.200    <none>        Ubuntu 20.04.2 LTS   5.8.0-55-generic   docker://20.10.2
k3s@master1:~/바탕화면$ 
