#!/bin/bash

set -e


echo "===================================="
echo "DPF Install ArgoCD"
echo "===================================="


ARGOCD_VERSION="stable"


echo "[1] Create namespace"


kubectl create namespace argocd \
--dry-run=client \
-o yaml | kubectl apply --server-side -f -


echo "[2] Download ArgoCD manifest"


mkdir -p /tmp/argocd


curl -L \
https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml \
-o /tmp/argocd/install.yaml



echo "[3] Remove huge kubectl annotations"


sed -i '/kubectl.kubernetes.io\/last-applied-configuration/d' \
/tmp/argocd/install.yaml



echo "[4] Install ArgoCD"


kubectl apply \
--server-side \
-n argocd \
-f /tmp/argocd/install.yaml



echo "[5] Wait ArgoCD"


kubectl wait \
--for=condition=Available \
deployment/argocd-server \
-n argocd \
--timeout=300s



echo "[6] Status"


kubectl get pods -n argocd


echo "===================================="
echo "DPF ArgoCD installation completed"
echo "===================================="

