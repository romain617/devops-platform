#!/bin/bash

set -e


echo "===================================="
echo "DPF Kubernetes Cluster Validation"
echo "===================================="


echo
echo "[1] Kubernetes API"

kubectl cluster-info


echo
echo "[2] Nodes status"

kubectl get nodes

NOT_READY=$(kubectl get nodes --no-headers | grep -v Ready || true)

if [ -n "$NOT_READY" ]; then
    echo "ERROR: Some nodes are not Ready"
    exit 1
fi


echo
echo "[3] System pods"

kubectl get pods -n kube-system


FAILED_SYSTEM=$(kubectl get pods -n kube-system \
--no-headers | awk '$3!="Running" {print}')


if [ -n "$FAILED_SYSTEM" ]; then
    echo "ERROR: Kubernetes system pods unhealthy"
    exit 1
fi


echo
echo "[4] Calico status"


kubectl get pods -n calico-system


FAILED_CALICO=$(kubectl get pods -n calico-system \
--no-headers | awk '$3!="Running" {print}')


if [ -n "$FAILED_CALICO" ]; then
    echo "ERROR: Calico unhealthy"
    exit 1
fi


echo
echo "[5] Cluster resources"


kubectl get nodes -o wide


echo
echo "===================================="
echo "DPF Cluster validation SUCCESS"
echo "===================================="

