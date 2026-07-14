#!/bin/bash

echo "Checking Kubernetes"

kubectl cluster-info


echo "Checking nodes"

kubectl get nodes


echo "Checking namespaces"

kubectl get ns


echo "DPF validation complete"
