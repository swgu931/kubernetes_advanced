# This is the change note for U+ Google Anthos MEC PoC

## Solution that solved ROS2 multicast issues
```
https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/try/gce-vms

## Compute Engine VM에서 Anthos clusters on bare metal 사용해 보기
https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/try/gce-vms


## 포드에 대한 다중 네트워크 인터페이스 구성
https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/how-to/multi-nic

thereafter the following code in deployment yaml was added

  template:
    metadata:
      annotations:
        k8s.v1.cni.cncf.io/networks: default/multicast  

```
