# Kubernetes-Saltstack
Saltstack recipe to deploy Kubernetes cluster from scratch.

## I - Preparation

Let's clone the git repo on a Salt-Master and create certificates on the `certs/` folder using `CfSSL tools`:

```
git clone git@github.com:valentin2105/Kubernetes-Saltstack.git /srv/salt
ln -s /srv/salt/pillar /srv/pillar

wget -q --show-progress --https-only --timestamping \
  https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
  https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
```

##### IMPORTANT Point
You need to add **every Hostnames off the Kubernetes cluster** (Master & Workers) in the  `certs/kubernetes-csr.json` (`hosts` field). You can also modify the `certs/*json` files to match your cluster-name / country. (mandatory)

```
cd /srv/salt/certs
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
```
After that, You need to tweak the `pillar/cluster_config.sls` to adapt version / config of Kubernetes :

```
k8s:
  apiServerHost: k8s-master.domain.tld 
  clusterDomain: cluster.local
  kubernetesVersion: v1.8.5
  etcdVersion: v3.2.11
  cniVersion: v0.6.0
  dockerVersion: 17.09.0-ce
  calicoCniVersion: v1.11.1
  calicoctlVersion: v1.3.0
  calicoNodeVersion: v2.6.3
  clusterIpRange: 10.32.0.0/16
  podsIPv4Range: 192.160.0.0/16
  enableIPv6: true
  enableIPv6NAT: true
  podsIPv6Range: fd80:24e2:f998:72d6::/64
  enableIPinIP: always
  calicoASnumber: 64512
  adminToken: ch@nG3mee
  calicoToken: ch@nG3mee
  kubeletToken: ch@nG3mee
```
##### Don't forget to change Tokens using command like `pwgen 64` !

## II - Deployment

To deploy your Kubernetes cluster using this Salt-recipe, you first need to setup your Saltstack Master/Minion. You can use Salt-Bootstrap to enhance the process. 

The configuration is done to use the Salt-Master as the Kubernetes-Master too but you can separate them if needed (the `post_install/script.sh` requiere `kubectl` and access to the `pillar` files).

#### The recommended configuration is :

- one Kubernetes-Master (also Salt-Master)

- one or more Kubernetes-Workers (also Salt-minion)

The Minion's roles are matched with `Salt Grains`, so you need to define theses grains on your servers :

```
# Kubernetes Master
echo "role: k8s-master" >> /etc/salt/grains

# Kubernetes Workers
echo "role: k8s-worker" >> /etc/salt/grains 
```

The master can also be a Kubernetes worker like that  (`/etc/salt/grains`) :

```
role:
  - k8s-master
  - k8s-worker
```

After that, you can apply your configuration (`highstate`) on Minions :

```
# Apply kubernetes Master
salt -G 'role:k8s-master' state.highstate

$ - kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health": "true"}

# Apply Kubernetes worker
salt -G 'role:k8s-worker' state.highstate

$ - kubectl get nodes
NAME                STATUS    ROLES     AGE       VERSION   EXTERNAL-IP   OS-IMAGE                       
k8s-salt-master     Ready     <none>    10h       v1.8.5    <none>        Debian GNU/Linux 9 (stretch) 
k8s-salt-worker01   Ready     <none>    7h        v1.8.5    <none>        Ubuntu 16.04.3 LTS 
```

To enable add-ons on the Kubernetes cluster, you can launch the `post_install/setup.sh` script :

```
/srv/salt/post_install/setup.sh
```

## III - Good to know

- Kubernetes-master H/A will be available soon (need some tests).
- It work and created for Debian / Ubuntu distributions. (PR welcome for Fedora/RedHat support).
- You can easily upgrade software version on your cluster by changing values in `pillar/cluster_config.sls` and apply a `state.highstate`.
- This configuration use ECDSA certificates (you can switch to `rsa` if needed in `certs/*.json`).
- If you add a node, just add the hostname in `kubernetes-csr.json` , relaunch the last `cfssl` command and apply a `state.highstate`
- This configuration use Calico as CNI-Provider, Policy-Controller and lauch Calico Node on all workers to share IP routes using BGP.
- You can tweak Pod's IPv4 Pool, enable IPv6, change IPv6 Pool, enable IPv6 NAT (for no-public networks), change BGP AS number, Enable IPinIP (to allow routes sharing of different cloud providers).

