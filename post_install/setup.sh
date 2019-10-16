#!/bin/bash

cd /opt/kubernetes/post_install

{% set HELM_VERSION = salt['pillar.get']('kubernetes:global:helm-version') -%}
{% set DASHBOARD_VERSION = salt['pillar.get']('kubernetes:global:dashboard-version') -%}

{% set PROVIDER = salt['pillar.get']('kubernetes:worker:networking:provider') -%}
{% if PROVIDER == "calico" -%}
kubectl create -f rbac-calico.yaml
kubectl create -f /opt/calico.yaml
sleep 15
{% endif %}

# CoreDNS
kubectl create -f coredns.yaml
sleep 5

# Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/{{ DASHBOARD_VERSION }}/aio/deploy/recommended.yaml

# Helm 
wget https://kubernetes-helm.storage.googleapis.com/helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
tar -zxvf helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -r linux-amd64/ && rm -r helm-{{ HELM_VERSION }}-linux-amd64.tar.gz

kubectl create -f rbac-tiller.yaml
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
helm init --client-only
sleep 20

# MetalLB
{% set METALLB_ENABLE = salt['pillar.get']('kubernetes:global:metallb:enable') -%}
{% set METALLB_VERSION = salt['pillar.get']('kubernetes:global:metallb:version') -%}

{% if METALLB_ENABLE == true -%}
kubectl apply -f https://raw.githubusercontent.com/google/metallb/{{ METALLB_VERSION }}/manifests/metallb.yaml
kubectl apply -f metallb-configmap.yaml
{% endif %}

# Nginx-Ingress
{% set NGINX_ENABLE = salt['pillar.get']('kubernetes:global:nginx-ingress:enable') -%}
{% set NGINX_VERSION = salt['pillar.get']('kubernetes:global:nginx-ingress:version') -%}
{% set NGINX_SVC = salt['pillar.get']('kubernetes:global:nginx-ingress:service-type') -%}

{% if NGINX_ENABLE == true -%}
helm install \
  --namespace nginx-ingress \
  --name nginx-ingress \
  --set controller.image.tag={{NGINX_VERSION}} \
  --set controller.service.type={{NGINX_SVC}} stable/nginx-ingress
{% endif %}

#Cert-Manager (Helm)
{% set CERT_MANAGER_ENABLE = salt['pillar.get']('kubernetes:global:cert-manager:enable') -%}
{% set CERT_MANAGER_VERSION = salt['pillar.get']('kubernetes:global:cert-manager:version') -%}
{% if CERT_MANAGER_ENABLE == true -%}
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version {{ CERT_MANAGER_VERSION }} \
  jetstack/cert-manager
{% endif %}


sleep 2
echo ""
kubectl get pod,deploy,svc --all-namespaces
echo ""
kubectl get nodes
echo ""
echo "Kubernetes is now configured with Policy-Controller, Dashboard, Helm and CoreDNS..."
echo ""
