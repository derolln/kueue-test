#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Submitting 6 test pods to Kueue (BestEffortFIFO queue)..."
kubectl apply -f "${SCRIPT_DIR}/manifests/test-pods.yaml"

echo ""
echo "==> Watching pods (Ctrl+C to stop)..."
echo "    Kueue will admit pods based on available quota in BestEffortFIFO order."
echo "    ClusterQueue quota: 4 CPU / 4Gi — each pod requests 250m CPU / 64Mi."
echo "    All 6 pods fit simultaneously (6 x 250m = 1.5 CPU total)."
echo ""

kubectl get pods -w --field-selector=metadata.namespace=default \
  -l kueue.x-k8s.io/queue-name=test-local-queue
