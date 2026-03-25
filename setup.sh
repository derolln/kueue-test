#!/usr/bin/env bash
set -euo pipefail

KUEUE_VERSION="${KUEUE_VERSION:-v0.9.1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting minikube..."
#minikube start

echo "==> Installing Kueue ${KUEUE_VERSION}..."
kubectl apply --server-side \
  -f "https://github.com/kubernetes-sigs/kueue/releases/download/${KUEUE_VERSION}/manifests.yaml"

# gcr.io/kubebuilder has been shut down; patch any reference to the mirror on quay.io.
echo "==> Patching kube-rbac-proxy image (gcr.io/kubebuilder is gone)..."
kubectl get deployment kueue-controller-manager -n kueue-system -o json \
  | sed 's|gcr.io/kubebuilder/kube-rbac-proxy|quay.io/brancz/kube-rbac-proxy|g' \
  | kubectl apply --server-side --force-conflicts -f -

echo "==> Waiting for Kueue controller to be ready..."
kubectl rollout status deployment/kueue-controller-manager \
  -n kueue-system --timeout=120s

echo "==> Patching Kueue config to enable pod integration..."
kubectl apply --server-side --force-conflicts \
  -f "${SCRIPT_DIR}/manifests/kueue-config.yaml"

echo "==> Restarting Kueue to pick up new config..."
kubectl rollout restart deployment/kueue-controller-manager -n kueue-system
kubectl rollout status deployment/kueue-controller-manager \
  -n kueue-system --timeout=120s

echo "==> Creating ResourceFlavor, ClusterQueue (BestEffortFIFO), LocalQueue..."
kubectl apply -f "${SCRIPT_DIR}/manifests/resource-flavor.yaml"
kubectl apply -f "${SCRIPT_DIR}/manifests/cluster-queue.yaml"
kubectl apply -f "${SCRIPT_DIR}/manifests/local-queue.yaml"

echo ""
echo "Setup complete. Run ./run-pods.sh to submit test pods."
