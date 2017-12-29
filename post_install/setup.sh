#!/bin/bash

cd /srv/salt/post_install/

HELM_VERSION=$(cat /srv/salt/pillar/cluster_config.sls |grep helm-version |sed  's/^.*: //g')
CLUSTER_DOMAIN=$(cat /srv/salt/pillar/cluster_config.sls |grep domain |sed  's/^.*: //g')
MASTER_HOSTNAME=$(cat /srv/salt/pillar/cluster_config.sls |grep hostname |sed  's/^.*: //g')

sed -i -e "s/CLUSTER_DOMAIN/$CLUSTER_DOMAIN/g" policy-controller.yaml
sed -i -e "s/MASTER_HOSTNAME/$MASTER_HOSTNAME/g" policy-controller.yaml
sed -i -e "s/CLUSTER_DOMAIN/$CLUSTER_DOMAIN/g" kube-dns.yaml
sed -i -e "s/MASTER_HOSTNAME/$MASTER_HOSTNAME/g" kube-dns.yaml

kubectl create -f rbac-calico.yaml
kubectl create -f policy-controller.yaml
sleep 10
kubectl create -f kube-dns.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl create -f heapster-rbac.yaml
kubectl create -f influxdb.yaml
kubectl create -f grafana.yaml
kubectl create -f heapster.yaml

wget https://kubernetes-helm.storage.googleapis.com/helm-$HELM_VERSION-linux-amd64.tar.gz
tar -zxvf helm-$HELM_VERSION-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -r linux-amd64/ && rm -r helm-$HELM_VERSION-linux-amd64.tar.gz

kubectl create serviceaccount tiller --namespace kube-system

kubectl create -f rbac-tiller.yaml
helm init --service-account tiller

sleep 2
echo ""
echo "Kubernetes is now configured with Policy-Controller, Dashboard, Helm and Kube-DNS..."
echo ""
kubectl get pod,deploy,svc --all-namespaces
echo ""
kubectl get nodes
echo ""
