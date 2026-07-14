#!/bin/bash

set -e


echo "===================================="
echo "DPF Install containerd.io"
echo "===================================="


echo "[1] Install repository tools"


dnf install -y \
dnf-plugins-core \
curl \
ca-certificates


echo "[2] Add Docker repository"


dnf config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo



echo "[3] Install containerd"


dnf install -y containerd.io



echo "[4] Configure containerd"


mkdir -p /etc/containerd


containerd config default > /etc/containerd/config.toml



echo "[5] Enable systemd cgroup"


sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml



echo "[6] Enable service"


systemctl enable containerd

systemctl restart containerd



echo "[7] Validation"


containerd --version


systemctl status containerd --no-pager


echo "===================================="
echo "containerd installation completed"
echo "===================================="

