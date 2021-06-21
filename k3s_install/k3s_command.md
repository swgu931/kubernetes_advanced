# command list for k3s


## command for master and worker node status in master node                                                         
```
sudo systemctl status k3s
sudo systemctl status k3s.service

sudo journalctl -u k3s.service

sudo kubectl get node
sudo kubectl get pod --namespace=kube-system
```

## command for worker node status in workder node
```
sudo systemctl status k3s-agent.service
sudo journalctl -u k3s-agent.service
```