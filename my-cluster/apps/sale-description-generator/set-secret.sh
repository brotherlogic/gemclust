#!/bin/bash

# Check if the API key is provided
if [ -z "$1" ]; then
    echo "Usage: ./set-secret.sh <GEMINI_API_KEY>"
    exit 1
fi

GEMINI_API_KEY=$1

# Create the secret in the sale-description-generator namespace
# This script uses kubectl to apply the secret.
# Ensure you are connected to the correct cluster.

kubectl create secret generic gemini-api-key \
    --from-literal=GEMINI_API_KEY=$GEMINI_API_KEY \
    -n sale-description-generator \
    --dry-run=client -o yaml | kubectl apply -f -
