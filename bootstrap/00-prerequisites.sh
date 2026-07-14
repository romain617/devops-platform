#!/bin/bash

set -e

echo "===================================="
echo "DPF Kubernetes OS Preparation"
echo "===================================="

service firewalld stop

echo "[1] Disable swap"

swapoff -a

sed -i '/ swap / s/^/#/' /etc/fstab



echo "[2] Kernel modules"

cat <<MODULES > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
MODULES


modprobe overlay
modprobe br_netfilter



echo "[3] Kubernetes sysctl"

cat <<SYSCTL > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
SYSCTL


sysctl --system



echo "[4] Install packages"


dnf install -y \
curl \
wget \
vim \
git \
tar \
jq \
bash-completion \
conntrack-tools \
socat



echo "[5] Disable SELinux enforcement"

setenforce 0 || true

sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config



echo "DPF OS prerequisites completed"

