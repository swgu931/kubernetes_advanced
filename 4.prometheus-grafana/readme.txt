# Prometheus-Grafana


k3s@master:~$ mkdir prometheus
k3s@master:~$ cd prometheus
k3s@master:~/prometheus$ cat > prometheus-cluster-role.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
  namespace: monitoring
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: default
  namespace: monitoring

k3s@master:~/prometheus$ 
k3s@master:~/prometheus$ 
k3s@master:~/prometheus$ 
k3s@master:~/prometheus$ cat > prometheus-config-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server-conf
  labels:
    name: prometheus-server-conf
  namespace: monitoring
data:
  prometheus.rules: |-
    groups:
    - name: container memory alert
      rules:
      - alert: container memory usage rate is very high( > 55%)
        expr: sum(container_memory_working_set_bytes{pod!="", name=""})/ sum (kube_node_status_allocatable_memory_bytes) * 100 > 55
        for: 1m
        labels:
          severity: fatal
        annotations:
          summary: High Memory Usage on {{ $labels.instance }}
          identifier: "{{ $labels.instance }}"
          description: "{{ $labels.job }} Memory Usage: {{ $value }}"
    - name: container CPU alert
      rules:
      - alert: container CPU usage rate is very high( > 10%)
        expr: sum (rate (container_cpu_usage_seconds_total{pod!=""}[1m])) / sum (machine_cpu_cores) * 100 > 10
        for: 1m
        labels:
          severity: fatal
        annotations:
          summary: High Cpu Usage
  prometheus.yml: |-
    global:
      scrape_interval: 5s
      evaluation_interval: 5s
    rule_files:
      - /etc/prometheus/prometheus.rules
    alerting:
      alertmanagers:
      - scheme: http
        static_configs:
        - targets:
          - "alertmanager.monitoring.svc:9093"

    scrape_configs:
      - job_name: 'kubernetes-apiservers'

        kubernetes_sd_configs:
        - role: endpoints
        scheme: https

        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https

      - job_name: 'kubernetes-nodes'

        scheme: https

        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

        kubernetes_sd_configs:
        - role: node

        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics


      - job_name: 'kubernetes-pods'

        kubernetes_sd_configs:
        - role: pod

        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name

      - job_name: 'kube-state-metrics'
        static_configs:
          - targets: ['kube-state-metrics.kube-system.svc.cluster.local:8080']

      - job_name: 'kubernetes-cadvisor'

        scheme: https

        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

        kubernetes_sd_configs:
        - role: node

        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor

      - job_name: 'kubernetes-service-endpoints'

        kubernetes_sd_configs:
        - role: endpoints

        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name
k3s@master:~/prometheus$ 


k3s@master:~/prometheus$ cat > prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-deployment
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus-server
  template:
    metadata:
      labels:
        app: prometheus-server
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:latest
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus/"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: prometheus-config-volume
              mountPath: /etc/prometheus/
            - name: prometheus-storage-volume
              mountPath: /prometheus/
      volumes:
        - name: prometheus-config-volume
          configMap:
            defaultMode: 420
            name: prometheus-server-conf

        - name: prometheus-storage-volume
          emptyDir: {}




k3s@master:~/prometheus$ cat > prometheus-node-exporter.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    k8s-app: node-exporter
spec:
  selector:
    matchLabels:
      k8s-app: node-exporter
  template:
    metadata:
      labels:
        k8s-app: node-exporter
    spec:
      containers:
      - image: prom/node-exporter
        name: node-exporter
        ports:
        - containerPort: 9100
          protocol: TCP
          name: http
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: node-exporter
  name: node-exporter
  namespace: kube-system
spec:
  ports:
  - name: http
    port: 9100
    nodePort: 31672
    protocol: TCP
  type: NodePort
  selector:
    k8s-app: node-exporter
k3s@master:~/prometheus$


k3s@master:~/prometheus$ cat > prometheus-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus-service
  namespace: monitoring
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '9090'
spec:
  selector:
    app: prometheus-server
  type: NodePort
  ports:
    - port: 8080
      targetPort: 9090
      nodePort: 30003
k3s@master:~/prometheus$ 


k3s@master:~/prometheus$ kubectl create ns monitoring
k3s@master:~/prometheus$ kubectl apply -f prometheus-cluster-role.yaml
k3s@master:~/prometheus$ kubectl apply -f prometheus-config-map.yaml
k3s@master:~/prometheus$ kubectl apply -f prometheus-deployment.yaml
k3s@master:~/prometheus$ kubectl apply -f prometheus-node-exporter.yaml
k3s@master:~/prometheus$ kubectl apply -f prometheus-svc.yaml


k3s@master:~/prometheus$ kubectl get pod -n monitoring
NAME                                     READY   STATUS    RESTARTS   AGE
prometheus-deployment-78675675d9-lbhf4   1/1     Running   0          5m10s
node-exporter-mprhf                      1/1     Running   0          2m54s
node-exporter-gz646                      1/1     Running   0          2m54s
k3s@master:~/prometheus$ 




k3s@master:~/prometheus$ cat > cluster-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/version: v1.8.0
  name: kube-state-metrics
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - nodes
  - pods
  - services
  - resourcequotas
  - replicationcontrollers
  - limitranges
  - persistentvolumeclaims
  - persistentvolumes
  - namespaces
  - endpoints
  verbs:
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - deployments
  - replicasets
  - ingresses
  verbs:
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - statefulsets
  - daemonsets
  - deployments
  - replicasets
  verbs:
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - list
  - watch
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - list
  - watch
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests
  verbs:
  - list
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  - volumeattachments
  verbs:
  - list
  - watch
- apiGroups:
  - admissionregistration.k8s.io
  resources:
  - mutatingwebhookconfigurations
  - validatingwebhookconfigurations
  verbs:
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - networkpolicies
  verbs:
  - list
  - watch


k3s@master:~/prometheus$ cat > cluster-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/version: v1.8.0
  name: kube-state-metrics
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
  namespace: kube-system
k3s@master:~/prometheus$ 

k3s@master:~/prometheus$ cat > service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/version: v1.8.0
  name: kube-state-metrics
  namespace: kube-system
k3s@master:~/prometheus$ cat > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/version: v1.8.0
  name: kube-state-metrics
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: kube-state-metrics
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kube-state-metrics
        app.kubernetes.io/version: v1.8.0
    spec:
      containers:
      - image: quay.io/coreos/kube-state-metrics:v1.8.0
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          timeoutSeconds: 5
        name: kube-state-metrics
        ports:
        - containerPort: 8080
          name: http-metrics
        - containerPort: 8081
          name: telemetry
        readinessProbe:
          httpGet:
            path: /
            port: 8081
          initialDelaySeconds: 5
          timeoutSeconds: 5
      nodeSelector:
        kubernetes.io/os: linux
      serviceAccountName: kube-state-metrics
k3s@master:~/prometheus$


k3s@master:~/prometheus$ kubectl apply -f cluster-role-binding.yaml
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
k3s@master:~/prometheus$ kubectl apply -f cluster-role.yaml
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
k3s@master:~/prometheus$ kubectl apply -f deployment.yaml
deployment.apps/kube-state-metrics created
k3s@master:~/prometheus$ kubectl apply -f service-account.yaml
serviceaccount/kube-state-metrics created
k3s@master:~/prometheus$ kubectl apply -f service.yaml
service/kube-state-metrics created
k3s@master:~/prometheus$ kubectl get pod -n kube-system
NAME                                     READY   STATUS    RESTARTS   AGE
local-path-provisioner-6d59f47c7-jcdhn   1/1     Running   0          141m
coredns-8655855d6-z24hg                  1/1     Running   0          141m
metrics-server-6cd998ff87-v229m          1/1     Running   0          63m
kube-state-metrics-7ffcdb8cfc-xd7hp      1/1     Running   0          15s
k3s@master:~/prometheus$ 




k3s@master:~/prometheus$ wget https://github.com/prometheus/node_exporter/releases/download/v0.16.0-rc.1/node_exporter-0.16.0-rc.1.linux-amd64.tar.gz
--2021-06-16 15:47:47--  https://github.com/prometheus/node_exporter/releases/download/v0.16.0-rc.1/node_exporter-0.16.0-rc.1.linux-amd64.tar.gz
github.com (github.com)을(를) 해석하는 중... 15.164.81.167
접속 github.com (github.com)|15.164.81.167|:443... 접속됨.
HTTP 요청을 전송했습니다. 응답을 기다리는 중입니다... 302 Found
위치: https://github-releases.githubusercontent.com/9524057/822c0ed4-3842-11e8-91ae-c3cbf5742170?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210616%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210616T064748Z&X-Amz-Expires=300&X-Amz-Signature=9f5f63b5e657ef24b770299a34c79d5c6d67dd0fb3fbdb78e9c18b551904e6d4&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=9524057&response-content-disposition=attachment%3B%20filename%3Dnode_exporter-0.16.0-rc.1.linux-amd64.tar.gz&response-content-type=application%2Foctet-stream [따라감]
--2021-06-16 15:47:48--  https://github-releases.githubusercontent.com/9524057/822c0ed4-3842-11e8-91ae-c3cbf5742170?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210616%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210616T064748Z&X-Amz-Expires=300&X-Amz-Signature=9f5f63b5e657ef24b770299a34c79d5c6d67dd0fb3fbdb78e9c18b551904e6d4&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=9524057&response-content-disposition=attachment%3B%20filename%3Dnode_exporter-0.16.0-rc.1.linux-amd64.tar.gz&response-content-type=application%2Foctet-stream
github-releases.githubusercontent.com (github-releases.githubusercontent.com)을(를) 해석하는 중... 185.199.109.154, 185.199.110.154, 185.199.108.154, ...
접속 github-releases.githubusercontent.com (github-releases.githubusercontent.com)|185.199.109.154|:443... 접속됨.
HTTP 요청을 전송했습니다. 응답을 기다리는 중입니다... 200 OK
길이: 5617869 (5.4M) [application/octet-stream]
다음 위치에 저장: `node_exporter-0.16.0-rc.1.linux-amd64.tar.gz'

node_exporter-0.16.0-rc.1.linux- 100%[==========================================================>]   5.36M  8.70MB/s    / 0.6s     

2021-06-16 15:47:49 (8.70 MB/s) - `node_exporter-0.16.0-rc.1.linux-amd64.tar.gz' 저장됨 [5617869/5617869]

k3s@master:~/prometheus$ 

k3s@master:~/prometheus$ ls
cluster-role-binding.yaml  node_exporter-0.16.0-rc.1.linux-amd64.tar.gz  prometheus-deployment.yaml     service-account.yaml
cluster-role.yaml          prometheus-cluster-role.yaml                  prometheus-node-exporter.yaml  service.yaml
deployment.yaml            prometheus-config-map.yaml                    prometheus-svc.yaml
k3s@master:~/prometheus$ tar -xzvf node_exporter-0.16.0-rc.1.linux-amd64.tar.gz
node_exporter-0.16.0-rc.1.linux-amd64/
node_exporter-0.16.0-rc.1.linux-amd64/LICENSE
node_exporter-0.16.0-rc.1.linux-amd64/node_exporter
node_exporter-0.16.0-rc.1.linux-amd64/NOTICE
k3s@master:~/prometheus$ mv node_exporter-0.16.0-rc.1.linux-amd64 node_exporter
k3s@master:~/prometheus$ ls
cluster-role-binding.yaml  node_exporter                                 prometheus-config-map.yaml     prometheus-svc.yaml
cluster-role.yaml          node_exporter-0.16.0-rc.1.linux-amd64.tar.gz  prometheus-deployment.yaml     service-account.yaml
deployment.yaml            prometheus-cluster-role.yaml                  prometheus-node-exporter.yaml  service.yaml
k3s@master:~/prometheus$ 

k3s@master:/etc/systemd/system$ sudo nano node_exporter.service
[sudo] k3s의 암호: 
k3s@master:/etc/systemd/system$ 



[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/home/admin/k8s/prometheus/server-node-exporter/node_exporter/node_exporter <-node_exporter가 설치된 디렉토리를 적는다

[Install]
WantedBy=default.target


k3s@master:/etc/systemd/system$ systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Wed 2021-06-16 15:52:44 KST; 34s ago
   Main PID: 63594 (code=exited, status=217/USER)

 6월 16 15:52:44 master.example.com systemd[1]: Started Node Exporter.
 6월 16 15:52:44 master.example.com systemd[1]: node_exporter.service: Main process exited, code=exited, status=217/USER
 6월 16 15:52:44 master.example.com systemd[1]: node_exporter.service: Failed with result 'exit-code'.



+++++++++++++++++++++++++++++++++++++++++++++


Prometheus와 Grafana 연동으로 모니터링 대쉬보드 구축하기


k3s@master:~/prometheus$ cat > grafana-datasource-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  prometheus.yaml: |-
    {
        "apiVersion": 1,
        "datasources": [
            {
               "access":"proxy",
                "editable": true,
                "name": "prometheus",
                "orgId": 1,
                "type": "prometheus",
                "url": "http://prometheus-service.monitoring.svc:8080",
                "version": 1
            }
        ]
    }


k3s@master:~/prometheus$


k3s@master:~/prometheus$ cat > grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      name: grafana
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - name: grafana
          containerPort: 3000
        resources:
          limits:
            memory: "2Gi"
            cpu: "1000m"
          requests:
            memory: "1Gi"
            cpu: "500m"
        volumeMounts:
          - mountPath: /var/lib/grafana
            name: grafana-storage
          - mountPath: /etc/grafana/provisioning/datasources
            name: grafana-datasources
            readOnly: false
      volumes:
        - name: grafana-storage
          emptyDir: {}
        - name: grafana-datasources
          configMap:
              defaultMode: 420
              name: grafana-datasources

              
k3s@master:~/prometheus$ cat > grafana-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '3000'
spec:
  selector:
    app: grafana
  type: NodePort
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 30004
k3s@master:~/prometheus$ 



k3s@master:~/prometheus$ kubectl apply -f grafana-datasource-config.yaml
configmap/grafana-datasources created
k3s@master:~/prometheus$ kubectl apply -f grafana-deployment.yaml
deployment.apps/grafana created
k3s@master:~/prometheus$ kubectl apply -f grafana-service.yaml
service/grafana created
k3s@master:~/prometheus$ 



k3s@master:~/prometheus$ 
k3s@master:~/prometheus$ kubectl get pod -n monitoring
NAME                                     READY   STATUS    RESTARTS   AGE
prometheus-deployment-78675675d9-lbhf4   1/1     Running   0          44m
node-exporter-mprhf                      1/1     Running   0          42m
node-exporter-gz646                      1/1     Running   0          42m
grafana-86b84774bb-jb6wn                 1/1     Running   0          32s
k3s@master:~/prometheus$ 

