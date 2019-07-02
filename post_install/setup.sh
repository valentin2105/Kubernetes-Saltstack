#!/bin/bash

{% set HELM_VERSION = salt['pillar.get']('kubernetes:global:helm-version') -%}

kubectl create -f https://docs.projectcalico.org/v3.7/manifests/calico.yaml
sleep 10
#kubectl -n kube-system edit configmap coredns #remove loop to resolve coredns issue
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml

#kubectl create -f heapster-rbac.yaml
#kubectl create -f influxdb.yaml
#kubectl create -f grafana.yaml
#kubectl create -f heapster.yaml

wget https://kubernetes-helm.storage.googleapis.com/helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
tar -zxvf helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -r linux-amd64/ && rm -r helm-{{ HELM_VERSION }}-linux-amd64.tar.gz

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
