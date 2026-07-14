#!/bin/bash

set -e

echo "===================================="
echo "DPF ArgoCD Bootstrap"
echo "===================================="


ARGOCD_NAMESPACE="argocd"


echo "[1] Validation ArgoCD"

kubectl get pods -n ${ARGOCD_NAMESPACE}


echo "[2] Deploy DPF Project"

kubectl apply \
-f platform/argocd/projects/dpf-project.yaml


echo "[3] Deploy Root Application"

kubectl apply \
-f platform/argocd/root-app/dev/root-application.yaml


echo "[4] Validation Project"

kubectl get appproject \
-n ${ARGOCD_NAMESPACE}


echo "[5] Validation Applications"

kubectl get applications \
-n ${ARGOCD_NAMESPACE}


echo "===================================="
echo "DPF ArgoCD Bootstrap OK"
echo "===================================="

