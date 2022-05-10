# How to enable ROS2 multicast message within Kubernetes cluster

## 클러스터에 multus와 macvlan 적용
### 1) install multus
- What is multus?
   
   : ref: https://ubuntu.com/blog/multus-how-to-escape-the-kubernetes-eth0-prison

```
git clone https://github.com/intel/multus-cni.git
cd multus-cni/
cat ./images/multus-daemonset.yml | kubectl apply -f -

# validate installation
kubectl get pods --all-namespaces | grep -i multus
```

### 2) macvlan 설정: spec.config.master는 machine의 network interface로 한다.

```
cat <<EOF | kubectl create -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-conf
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      # your master's network interface
      "master": "eth0",
      "mode": "bridge",
      "isDefaultgateway": true,
      "ipam": {
        "type": "host-local",
        "subnet": "192.168.1.0/24",
        "rangeStart": "192.168.1.200",
        "rangeEnd": "192.168.1.216",
        "routes": [
          { "dst": "0.0.0.0/0" }
        ],
        "gateway": "192.168.1.1"
      }
    }'
EOF

# check macvlan-conf
kubectl get network-attachment-definitions
kubectl describe network-attachment-definitions macvlan-conf
```

### 3) Be sure ros2 test message be multicasted by Adding annotations
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ros-talker-deployment
  labels:
    app: ros-talker
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ros-talker
  template:
    metadata:
      labels:
        app: ros-talker
      annotations:
        k8s.v1.cni.cncf.io/networks: macvlan-conf
    spec:
      containers:
      - name: talker 
        image: ros:foxy
        command: ["/bin/bash", "-c"]
        args: ["source /opt/ros/foxy/setup.bash && apt update && apt install -y curl && curl https://raw.githubusercontent.com/canonical/robotics-blog-k8s/main/publisher.py > publisher.py && /bin/python3 publisher.py talker"]

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ros-listener-deployment
  labels:
    app: ros-listener
  annotations:
    k8s.v1.cni.cncf.io/networks: macvlan-conf
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ros-listener
  template:
    metadata:
      labels:
        app: ros-listener
      annotations:
        k8s.v1.cni.cncf.io/networks: macvlan-conf
    spec:
      containers:
      - name: listener
        image: ros:foxy
        command: ["/bin/bash", "-c"]
        args: ["source /opt/ros/foxy/setup.bash && apt update && apt install -y curl && curl https://raw.githubusercontent.com/canonical/robotics-blog-k8s/main/subscriber.py > subscriber.py && /bin/python3 subscriber.py listener"]
```
