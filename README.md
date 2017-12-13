# Kubernetes-Saltstack
A Saltstack recipe to deploy Kubernetes cluster. 

## I - Preparation

To prepare the deployment of the Kubernetes cluster, you need to create certificates on the `certs/` folder using `CFSSL tool`: 

```
wget ...

```

After that, you need to tweak the `pillar/cluster_config.sls` to adapt version / configuration of Kubernetes : 

```


```


## II - Deployment

To deploy your Kubernetes cluster using this Salt-recipe, you first need to setup your Saltstack Master/Minion. 
The Kubernetes Master can also be the Salt Master if you want a small number of servers. 

#### The recommanded configuration is : 

- a Salt-Master VM
- a Kubernetes-Master (also Salt-minion)
- one or more Kubernetes-Workers (also Salt-minion)

The Minion's roles are matched with Salt Grains, so you need to apply theses grains on your servers : 

`echo "role: k8s-master" >> /etc/salt/grains (on Kubernetes master)`

`echo "role: k8s-worker" >> /etc/salt/grains (on Kubernetes workers)`


After that, you can apply your configuration on your minions :

```
# Install Master
salt -G 'roles:k8s-master' state.highstate

# Install Worker
salt -G 'roles:k8s-worker' state.highstate

```

