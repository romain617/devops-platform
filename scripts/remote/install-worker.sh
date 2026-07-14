#!/bin/bash
set -e

#FIREWAL 
service firewalld stop
systemctl disable firewalld

#HOSTNAME
hostnamectl set-hostname worker1

cat <<'HOSTIP' >> /etc/hosts
172.26.112.10   master
172.26.112.11   worker1
HOSTIP

# Réinitialiser kubeadm
kubeadm reset -f

# Arrêter les services
systemctl stop kubelet
systemctl stop containerd

# Nettoyer la configuration Kubernetes
rm -rf /etc/kubernetes
rm -rf /var/lib/kubelet
rm -rf /var/lib/etcd
rm -rf /var/lib/cni
rm -rf /etc/cni/net.d
rm -rf /run/flannel
rm -rf $HOME/.kube

# (Optionnel) Nettoyer les règles réseau
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

ipvsadm --clear 2>/dev/null || true


echo "===================================="
echo "DPF Worker Installation"
echo "===================================="


echo "[1.2] Configure Kubernetes repository"


cat <<REPO > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key
REPO

yum install -y yum-utils

#force route stable eth0
nmcli con mod "eth0" ipv4.route-metric 100

#autoriser forwarding
service firewalld stop
#firewall-cmd --permanent --add-forward
#firewall-cmd --reload

#SELinux désactivé temporaire
setenforce 0

#SELinux désactivé permanent
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

#REPO DOCKER CONTAINEZR
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "[1.3] Install containerd"
dnf install -y containerd.io

echo "[1.4] Configure containerd"
mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

echo "[1.5] Enable systemd cgroup"


sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

#conf kubernetes

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "[1.6] Enable service"


systemctl enable containerd

systemctl restart containerd


echo "[2] Install Kubernetes packages"


dnf install -y kubeadm kubelet kubectl


echo "[3] Enable kubelet"


systemctl enable --now kubelet


echo "[4] Join Kubernetes cluster"


KUBE_JOIN_COMMAND="kubeadm join 172.26.112.10:6443 --token vciqzd.vzsbwlzah5ir7ess --discovery-token-ca-cert-hash sha256:f7800f111b4a75ffc5c404a4c68b350e9ddcc07833f54f57f0f57cabdf59615a "


eval ${KUBE_JOIN_COMMAND}


echo "===================================="
echo "Worker joined successfully"
echo "===================================="

