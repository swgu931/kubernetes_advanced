# multi cluster access howto by examples
- https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/

```
cluster
-development
    namespace:  frontend, storage

-scratch
    namespace: default
```
```
mkdir config-excercise
cd config-excercise
vi config-demo

```
```
apiVersion: v1
kind: Config
preferences: {}

clusters:
- cluster:
  name: development
- cluster:
  name: scratch

users:
- name: developer
- name: experimenter

contexts:
- context:
  name: dev-frontend
- context:
  name: dev-storage
- context:
  name: exp-scratch
```

## to add cluster, user, context details to your configuration file
```
kubectl config --kubeconfig=config-demo set-cluster development --server=https://1.2.3.4 --certificate-authority=fake-ca-file
kubectl config --kubeconfig=config-demo set-cluster scratch --server=https://5.6.7.8 --insecure-skip-tls-verify

kubectl config --kubeconfig=config-demo set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
kubectl config --kubeconfig=config-demo set-credentials experimenter --username=exp --password=some-password

kubectl config --kubeconfig=config-demo set-context dev-frontend --cluster=development --namespace=frontend --user=developer
kubectl config --kubeconfig=config-demo set-context dev-storage --cluster=development --namespace=storage --user=developer
kubectl config --kubeconfig=config-demo set-context exp-scratch --cluster=scratch --namespace=default --user=experimenter
```
```
kubectl config --kubeconfig=config-demo view
```
```
The fake-ca-file, fake-cert-file and fake-key-file above are the placeholders for the pathnames of the certificate files. You need to change these to the actual pathnames of certificate files in your environment.

Sometimes you may want to use Base64-encoded data embedded here instead of separate certificate files; in that case you need to add the suffix -data to the keys, for example, certificate-authority-data, client-certificate-data, client-key-data.

Each context is a triple (cluster, user, namespace). For example, the dev-frontend context says, "Use the credentials of the developer user to access the frontend namespace of the development cluster".
```

## set current context
```
kubectl config --kubeconfig=config-demo use-context dev-frontend
```
## To see only the configuration information associated with the current context 
```
kubectl config --kubeconfig=config-demo view --minify
```

## Change the current context to exp-scratch:
```
kubectl config --kubeconfig=config-demo use-context exp-scratch
```
 
## Change the current context to dev-storage:
```
kubectl config --kubeconfig=config-demo use-context dev-storage
```

# Create a second configuration file 
- In your config-exercise directory, create a file named config-demo-2 with this content:
```
apiVersion: v1
kind: Config
preferences: {}

contexts:
- context:
    cluster: development
    namespace: ramp
    user: developer
  name: dev-ramp-up
```

## Set the KUBECONFIG environment variable
```
export KUBECONFIG=$HOME/.kube/config
export KUBECONFIG=$KUBECONFIG:config-demo:config-demo-2
```
