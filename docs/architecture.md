# DPF Architecture


## Overview

DPF is composed of:

- Kubernetes Cluster
- ArgoCD GitOps Engine
- Platform Components
- Environment overlays


## Deployment model

Bootstrap installs:

1. ArgoCD
2. Root Application
3. Platform components


## GitOps flow

Git
 |
 v
ArgoCD
 |
 v
Kubernetes Cluster
