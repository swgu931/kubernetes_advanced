

# ref : https://github.com/kubernetes-sigs/metrics-server
# wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml

vi component.yaml

---

      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server-amd64:v0.3.6
        imagePullPolicy: IfNotPresent
        args:
          - --cert-dir=/tmp
          - --secure-port=4443   
          - --kubelet-insecure-tls  #추가 
          - --kubelet-preferred-address-types=InternalP,ExternalIP,Hostname  #추가
---


kubectl top pods -n kube-system