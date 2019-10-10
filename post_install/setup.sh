#!/bin/bash

{% set HELM_VERSION = salt['pillar.get']('kubernetes:global:helm-version') -%}

kubectl create -f rbac-calico.yaml
kubectl create -f /opt/calico.yaml
sleep 10
kubectl create -f coredns.yaml

# Kubernetes Dashboard 2.0.0-beta4
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml

#kubectl create -f heapster-rbac.yaml
#kubectl create -f influxdb.yaml
#kubectl create -f grafana.yaml
#kubectl create -f heapster.yaml

wget https://kubernetes-helm.storage.googleapis.com/helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
tar -zxvf helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -r linux-amd64/ && rm -r helm-{{ HELM_VERSION }}-linux-amd64.tar.gz

kubectl create serviceaccount tiller --namespace kube-system
kubectl apply -f rbac-tiller.yaml
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -

sleep 2
echo ""
echo "Kubernetes is now configured with Policy-Controller, Dashboard, Helm and Kube-DNS..."
echo ""
kubectl get pod,deploy,svc --all-namespaces
echo ""
kubectl get nodes
echo ""
