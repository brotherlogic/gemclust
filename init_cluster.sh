#!/usr/bin/env bash

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <CONTROL_PLANE_IP> [WORKER_IP_1] [WORKER_IP_2] ..."
    exit 1
fi

CP_IP=$1
shift
WORKER_IPS=$@

mkdir -p talos

echo "Generating Talos configurations..."
talosctl gen config gemclust "https://${CP_IP}:6443" --output-dir talos/ --force

echo "Applying control plane configuration to ${CP_IP}..."
talosctl apply-config --insecure --nodes "${CP_IP}" --file talos/controlplane.yaml

echo "Waiting for control plane to settle (30s)..."
sleep 30

echo "Bootstrapping the cluster..."
talosctl bootstrap --nodes "${CP_IP}" --endpoints "${CP_IP}" --talosconfig talos/talosconfig

for WORKER_IP in ${WORKER_IPS}; do
    echo "Applying worker configuration to ${WORKER_IP}..."
    talosctl apply-config --insecure --nodes "${WORKER_IP}" --file talos/worker.yaml
done

echo "Fetching kubeconfig..."
talosctl kubeconfig --nodes "${CP_IP}" --endpoints "${CP_IP}" --talosconfig talos/talosconfig talos/kubeconfig

echo "Done! Kubeconfig is at talos/kubeconfig"
echo "You can use it with: export KUBECONFIG=\$(pwd)/talos/kubeconfig"
