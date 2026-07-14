#!/bin/bash

set -e

CONFIG_FILE="platform/kubernetes/kubeadm-config.yaml"

echo "===================================="
echo "DPF Initialize Kubernetes Control Plane"
echo "===================================="

echo "[1] kubeadm init"

kubeadm init --config ${CONFIG_FILE}

echo "[2] Configure kubectl"

mkdir -p "$HOME/.kube"
cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
export KUBECONFIG="$HOME/.kube/config"

echo "[3] Validation"

kubectl cluster-info

kubectl get nodes

echo "===================================="
echo "Control Plane initialized"
echo "===================================="

