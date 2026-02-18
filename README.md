# GKE Multi-Cluster Gateway (Global Load Balancing)

This repository contains the infrastructure-as-code to deploy a global multi-cluster application on Google Kubernetes Engine (GKE) using the Gateway API.

## Project Details
- **Project ID:** `test-project2-409608`
- **Regions:** `us-west1` (Config Cluster), `us-east1`
- **Domain:** `store.example.com` (Replace with your actual domain)

## Architecture
We use a **Global External Application Load Balancer** managed by the GKE Gateway Controller.
1. **Google Cloud LB** receives traffic on Anycast IP.
2. Traffic is routed to the **closest healthy cluster**.
3. If a region fails (Health Check fails), traffic automatically fails over to the next closest region.

## File Descriptions

### `apps/store.yaml`
* **Reason:** Defines the actual workload (Pods) and internal networking.
* **Use:**
    * `Deployment`: Runs the `nginxdemos/hello` app.
    * `ServiceExport`: **Crucial.** Tells the GKE Fleet that this service should be reachable by the Gateway. Without this, the Gateway cannot route traffic to these pods.

### `gateway/certificate.yaml`
* **Reason:** Security. We cannot serve production traffic over HTTP.
* **Use:** Requests a Google-managed SSL certificate. Google handles the provisioning and renewal automatically once you update your DNS.

### `gateway/gateway.yaml`
* **Reason:** The entry point. This *is* the Load Balancer configuration.
* **Use:**
    * Configures Port 443 (HTTPS) and attaches the certificate.
    * Defines `HTTPRoute` rules to map URL paths to the `store-service`.

### `gateway/health-check.yaml`
* **Reason:** High Availability. The Load Balancer needs to know when a region is down.
* **Use:**
    * Overrides default health checks.
    * **Logic:** Checks root path `/` every 10s. Fails after 3 attempts.
    * **Result:** Triggers failover in ~30 seconds if a region dies.

---

## Load Testing / Failover Simulation

To verify the multi-region resilience, follow these steps:

### 1. Start Traffic Loop
Run this command to monitor which region is serving your request.
```bash
while true; do curl -s [https://store.example.com](https://store.example.com) | grep "Server Name"; sleep 1; done
