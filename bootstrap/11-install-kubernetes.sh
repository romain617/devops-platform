#!/bin/bash

set -e


echo "===================================="
echo "DPF Install Kubernetes Components"
echo "===================================="


echo "[1] Add Kubernetes repository"


cat <<REPO > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key
REPO


echo "[2] Install kubeadm kubelet kubectl"


dnf install -y \
kubelet \
kubeadm \
kubectl



echo "[3] Enable kubelet"


systemctl enable kubelet



echo "[4] Hold Kubernetes packages"

dnf versionlock add kubelet kubeadm kubectl || true



echo "[5] Versions"


kubeadm version

kubectl version --client

kubelet --version



echo "===================================="
echo "Kubernetes components installed"
echo "===================================="

