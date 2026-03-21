#!/usr/bin/env bash

# This script bootstraps Flux into a Kubernetes cluster using a GitHub repository.
# Prerequisites:
# 1. A Kubernetes cluster running and your kubeconfig pointing to it.
# 2. The 'flux' CLI installed (https://fluxcd.io/flux/cmd/).
# 3. A GitHub Personal Access Token (PAT) with repo permissions exported as GITHUB_TOKEN.

set -e

# Repository configuration
# We default to the current repository name 'gemclust' and user 'brotherlogic' based on workspace context.
GITHUB_USER=${GITHUB_USER:-"brotherlogic"}
GITHUB_REPO=${GITHUB_REPO:-"gemclust"}
BRANCH=${BRANCH:-"main"}

# The path in the repository where the Flux cluster configuration will be stored.
CLUSTER_PATH=${CLUSTER_PATH:-"my-cluster"}

# Check if GITHUB_TOKEN is set
if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Error: GITHUB_TOKEN environment variable is not set."
  echo "Please generate a Personal Access Token with 'repo' permissions and export it:"
  echo "export GITHUB_TOKEN=<your-token>"
  exit 1
fi

echo "🚀 Bootstrapping Flux to the cluster..."
echo "Owner:      ${GITHUB_USER}"
echo "Repository: ${GITHUB_REPO}"
echo "Branch:     ${BRANCH}"
echo "Path:       ${CLUSTER_PATH}"

# Run the flux bootstrap command
flux bootstrap github \
  --owner="${GITHUB_USER}" \
  --repository="${GITHUB_REPO}" \
  --branch="${BRANCH}" \
  --path="${CLUSTER_PATH}" \
  --toleration-keys="node-role.kubernetes.io/master,node-role.kubernetes.io/control-plane" \
  --personal

echo "✅ Flux bootstrap complete! Your cluster is now synced with the ${GITHUB_REPO} repository."
