#!/bin/bash
# tests/simulate-failure.sh

PROJECT_ID="test-project2-409608"
REGION_WEST="us-west1"
CLUSTER_WEST="gke-west"
CTX_WEST="gke_${PROJECT_ID}_${REGION_WEST}_${CLUSTER_WEST}"

echo "=========================================="
echo "      GKE REGION FAILOVER SIMULATOR       "
echo "=========================================="
echo "Target Cluster: $CLUSTER_WEST ($REGION_WEST)"
echo ""

# STEP 1: FAILURE
read -p "Press [Enter] to SIMULATE OUTAGE (Scale to 0)..."
echo "Testing outage..."
kubectl scale deployment store-app --replicas=0 --context=$CTX_WEST
echo "❌ $CLUSTER_WEST is now DOWN."
echo "👉 Check your load test terminal. Traffic should shift to East in ~30s."

echo ""
echo "------------------------------------------"
echo ""

# STEP 2: RECOVERY
read -p "Press [Enter] to RECOVER REGION (Scale to 2)..."
echo "Recovering..."
kubectl scale deployment store-app --replicas=2 --context=$CTX_WEST
echo "✅ $CLUSTER_WEST is RECOVERING."
echo "👉 Traffic will shift back once health checks pass (~30-60s)."
