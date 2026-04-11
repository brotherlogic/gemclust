#!/usr/bin/env bash

set -e

USAGE="Usage: $0 [-c] <MACHINE_IP>
Options:
  -c    Add as a control plane node (default is worker)
"

TYPE="worker"
while getopts "c" opt; do
  case ${opt} in
    c )
      TYPE="controlplane"
      ;;
    \? )
      echo "${USAGE}"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [ "$#" -ne 1 ]; then
    echo "${USAGE}"
    exit 1
fi

MACHINE_IP=$1
CONFIG_FILE="talos/${TYPE}.yaml"

if [ ! -f "${CONFIG_FILE}" ]; then
    echo "Error: ${CONFIG_FILE} not found. Did you run init_cluster.sh?"
    exit 1
fi

echo "Adding machine ${MACHINE_IP} as ${TYPE}..."
talosctl apply-config --insecure --nodes "${MACHINE_IP}" --file "${CONFIG_FILE}"

echo "Done!"
