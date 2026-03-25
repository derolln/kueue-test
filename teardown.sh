#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Deleting test pods..."
kubectl delete -f "${SCRIPT_DIR}/manifests/test-pods.yaml" --ignore-not-found

echo "==> Deleting Kueue queues and flavors..."
kubectl delete -f "${SCRIPT_DIR}/manifests/local-queue.yaml" --ignore-not-found
kubectl delete -f "${SCRIPT_DIR}/manifests/cluster-queue.yaml" --ignore-not-found
kubectl delete -f "${SCRIPT_DIR}/manifests/resource-flavor.yaml" --ignore-not-found

echo "==> Stopping minikube..."
#minikube stop

echo "Teardown complete."
