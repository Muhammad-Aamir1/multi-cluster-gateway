#!/bin/bash
PROJECT_ID="test-project2-409608"
CTX_WEST="gke_${PROJECT_ID}_us-west1_gke-west"
CTX_EAST="gke_${PROJECT_ID}_us-east1_gke-east"

echo "Deploying Applications..."
# Apply App to BOTH clusters
kubectl apply -f apps/store.yaml --context=$CTX_WEST
kubectl apply -f apps/store.yaml --context=$CTX_EAST

# Apply Health Checks to BOTH clusters
kubectl apply -f gateway/health-check.yaml --context=$CTX_WEST
kubectl apply -f gateway/health-check.yaml --context=$CTX_EAST

echo "Deploying Gateway Config..."
# Apply Gateway & Certs ONLY to Config Cluster (West)
kubectl apply -f gateway/certificate.yaml --context=$CTX_WEST
kubectl apply -f gateway/gateway.yaml --context=$CTX_WEST

echo "Deployment complete! Run 'kubectl get gateway global-gateway --context=$CTX_WEST' to get your IP."
