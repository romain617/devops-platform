#!/bin/bash

WORKER_IP="172.26.112.11"
WORKER_USER="root"

set -e

echo "===================================="
echo "DPF Worker Bootstrap"
echo "===================================="


echo "[1] Generate kubeadm join command"

JOIN_COMMAND=$(kubeadm token create --print-join-command)


echo "[2] Prepare worker script"

TMP_SCRIPT="/tmp/dpf-install-worker.sh"


sed "s|__JOIN_COMMAND__|${JOIN_COMMAND}|" \
scripts/remote/install-worker.sh \
> ${TMP_SCRIPT}


echo "[3] Copy script to worker"

scp ${TMP_SCRIPT} \
${WORKER_USER}@${WORKER_IP}:/tmp/dpf-install-worker.sh


echo "[4] Execute worker installation"

ssh ${WORKER_USER}@${WORKER_IP} \
"chmod +x /tmp/dpf-install-worker.sh && /tmp/dpf-install-worker.sh"


echo "[5] Wait worker registration"

sleep 20


echo "[6] Cluster status"

kubectl get nodes -o wide


echo "===================================="
echo "DPF Worker Bootstrap completed"
echo "===================================="

