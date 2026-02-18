#!/bin/bash
PROJECT_ID="test-project2-409608"

echo "Setting up infrastructure for $PROJECT_ID..."

# Enable APIs
gcloud services enable container.googleapis.com gkehub.googleapis.com \
    multiclusterservicediscovery.googleapis.com multiclusteringress.googleapis.com \
    trafficdirector.googleapis.com --project=$PROJECT_ID

# Create Clusters
gcloud container clusters create-auto gke-west --region=us-west1 --project=$PROJECT_ID
gcloud container clusters create-auto gke-east --region=us-east1 --project=$PROJECT_ID

# Register to Fleet
gcloud container fleet memberships register gke-west --gke-cluster=us-west1/gke-west --enable-workload-identity --project=$PROJECT_ID
gcloud container fleet memberships register gke-east --gke-cluster=us-east1/gke-east --enable-workload-identity --project=$PROJECT_ID

# Enable MCS
gcloud container fleet multi-cluster-services enable --project=$PROJECT_ID

# Enable Gateway (Config Cluster = West)
gcloud container fleet ingress enable \
    --config-membership=projects/$PROJECT_ID/locations/us-west1/memberships/gke-west \
    --project=$PROJECT_ID

echo "Infrastructure setup complete."
