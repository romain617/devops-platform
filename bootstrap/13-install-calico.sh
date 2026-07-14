#!/bin/bash

set -e

echo "===================================="
echo "DPF Install Calico"
echo "===================================="

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/calico.yaml

echo "[1] Installing Tigera Operator"

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/tigera-operator.yaml


echo "[2] Waiting for Tigera Operator"

kubectl wait \
    --for=condition=Available \
    deployment/tigera-operator \
    -n tigera-operator \
    --timeout=300s


echo "[3] Waiting for Calico CRDs"

until kubectl get crd installations.operator.tigera.io >/dev/null 2>&1
do
    echo "Waiting for Installation CRD..."
    sleep 5
done


echo "[4] Installing Calico Custom Resources"

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/custom-resources.yaml


echo "[5] Waiting for Calico"

kubectl wait \
    --for=condition=Available \
    deployment/calico-kube-controllers \
    -n calico-system \
    --timeout=300s


echo "[6] Cluster status"

kubectl get nodes

kubectl get pods -A


echo "===================================="
echo "Calico installation completed"
echo "===================================="

