    
# Kubernetes GitOps & Component Architecture

This repository defines the declarative state of my Kubernetes clusters. It implements a strict GitOps workflow where ArgoCD synchronizes the live state with the configuration defined here.

The architecture focuses on modularity and auditability. It uses **Kustomize Components** to standardize infrastructure dependencies (like Databases and Caching) and a **CI-driven hydration pipeline** to ensure every change to an upstream Helm chart is visible in git diffs.

## Core Architecture

### 1. Global Kustomize Components
To avoid copy-pasting complex YAML for stateful services, I utilize Kustomize Components.
*   **The Problem:** Applications like Netbox, Keycloak, and Harbor all need High-Availability Postgres (CloudNativePG) and Redis (Valkey). Defining these individually leads to drift.
*   **The Solution:** I define the "Gold Standard" configuration in the top-level `components/` directory. Applications import these components and overlay only what they need (e.g., the database name).

**Example:**
*   `components/cnpg-cluster`: Defines a production-ready Postgres cluster with backup schedules, S3 offloading, and monitoring.
        `apps/netbox/clusters/ops-prod/kustomization.yaml`: References `apps/netbox/clusters/ops-prod/cnpg/kustomization.yaml`, an application-specific reference to the component. 

### 2. Helm Inflation & Auditing
I do not use ArgoCD's native Helm handling. Instead, I use the Kustomize `HelmChartInflationGenerator`.
*   **Hydration:** At deployment time, Kustomize renders the Helm chart.
*   **Patching:** I apply local patches (overlays) to the rendered chart to inject sidecars or modify configurations not exposed by `values.yaml`.
*   **Audit Pipeline:** A GitLab CI pipeline renders the entire stack and commits the hydrated YAML back to a separate branch. This allows me to see exactly what changes an upstream Helm chart version bump will cause *before* it hits the cluster.

### 3. Secret Management
This project uses two distinct methods for handling sensitive data, backed by **HashiCorp Vault**:

*   **ArgoCD Vault Plugin (AVP):** Used for injecting secrets directly into manifests during the sync process.
*   **External Secrets Operator (ESO):** Used for lifecycle management. ESO creates native Kubernetes `Secret` resources by fetching data from Vault.

## Repository Structure

```text
.
├── apps/
│   ├── <app-name>/
│   │   ├── base/           # Shared configuration
│   │   ├── helm/           # Upstream Chart definition (Inflation Generator)
│   │   ├── components/     # App-specific mixins (e.g., ServiceMonitors)
│   │   └── clusters/       # Cluster overlays
├── components/             # GLOBAL Shared Infrastructure (The "DRY" layer)
│   ├── cnpg-cluster/       # Standardized Postgres definition
│   ├── valkey/             # Standardized Redis definition
│   └── ca-bundle/          # CA injection
├── clusters/               # ArgoCD ApplicationSets & Cluster Config
└── bootstrap/              # Initial Cluster Seeding

  

Workflow: From Commit to Cluster

    Change: I modify an application definition in apps/<name>/*.

    CI Audit: GitLab CI detects the change, runs kustomize build, and generates a diff of the hydrated manifests.

    Merge: Once approved and merged, ArgoCD detects the change.

    Sync:

        ApplicationSets ensure the app is targeted to the correct cluster.

        Kustomize inflates the Helm chart and pulls in the Global Components (e.g., Valkey).

        AVP replaces placeholder strings with actual secrets.

        Apply: The final manifest is applied to the cluster.

Key Technologies

    ArgoCD: Deployment controller and ApplicationSet logic.

    Kustomize: Configuration overlay, Helm inflation, and Component aggregation.

    CloudNativePG: Operator for orchestrating PostgreSQL workloads.

    Valkey: High-performance key-value store (Redis fork).

    Renovate: Automated dependency updates for Docker images and Helm charts..
