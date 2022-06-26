
# Kubernetes Operator : kudo
## Part4 Ch7 4 kubernetes Operator
- ref: https://github.com/DevOpsRunbook/FastCampus

```
OS=$(uname | tr '[:upper:]' '[:lower:]')
wget https://github.com/kudobuilder/kudo/releases/download/v0.19.0/kubectl-kudo_0.19.0_<*OS종류>_x86_64


chmod +x kubectl-kudo_0.19.0_<*OS종류>_x86_64 && mv kubectl-kudo_0.19.0_<*OS종류>_x86_64 /usr/local/bin/kubectl-kudo

kubectl kudo --version

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml

kubectl get pods --namespace cert-manager

kubectl kudo init

kubectl kudo install Ch07_04-kudo-operator/

kubectl kudo get operators

kubectl kudo get instances

kubectl kudo get all ‒o yaml

kubectl get all

kubectl get deploy ‒o yaml

kubectl kudo upgrade Ch07_04-kudo-operator/ --instance test-instance

kubectl kudo get all ‒o yaml

kubectl get all
```
