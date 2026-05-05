# Odoo 15 — Helm Chart sur Kubernetes

Déploiement complet d'Odoo 15 packagé en Helm Chart avec isolation Prod/Staging, stockage MinIO S3 et sessions PostgreSQL partagées.

## Architecture
<img width="933" height="1520" alt="Architecture-locale drawio" src="https://github.com/user-attachments/assets/ce80a894-5e07-4258-80b5-883346f5566d" />


helm-master-vm  (192.168.2.199) — Control Plane K8s v1.28
├── helm-worker1-vm → namespace: odoo-prod    (3 replicas)
└── helm-worker2-vm → namespace: odoo-staging (1 replica)
minio-vm (192.168.2.42)  → Object Storage S3 (filestore Odoo)
pg-vm    (192.168.2.114) → PostgreSQL 14 (sessions partagées)

## Stack technique

- Kubernetes v1.28 (kubeadm)
- Helm v3
- CNI : Cilium (L2 Announcements + LoadBalancer IP Pool 192.168.2.60/29)
- Ingress : Cilium Ingress (cookie affinity)
- Stockage : MinIO S3 + local-storage PVs
- Sessions : PostgreSQL via module session_db_with_timeout
- Filestore : MinIO via module s3_attachment_manager_v2

## Structure du chart
## 📁 Structure du projet
📦 odoo-k8s-ha/
├── 📄 README.md
├── 📄 .gitignore
├── 📁 helm-chart/
│   ├── 📄 Chart.yaml
│   ├── 📄 values.yaml
│   ├── 📄 values-prod.yaml
│   ├── 📄 values-staging.yaml
│   └── 📁 templates/
│       ├── 📄 _helpers.tpl
│       ├── 📄 configmap.yaml
│       ├── 📄 deployment.yaml
│       ├── 📄 ingress.yaml
│       ├── 📄 pv.yaml
│       ├── 📄 pvc.yaml
│       ├── 📄 secret.yaml
│       └── 📄 service.yaml
├── 📁 infrastructure/
│   └── 📄 cilium-lb-pool.yml
└── 📁 scripts/
├── 📄 deploy-prod.sh
└── 📄 deploy-staging.sh

## Features

- Zero-downtime Rolling Update (maxSurge=1, maxUnavailable=0)
- Readiness & Liveness probes (/web/health)
- PreStop hook — graceful shutdown 15s
- Sessions partagées via PostgreSQL
- Fichiers centralisés sur MinIO S3
- Prod/Staging isolés par namespace
- Cookie-based session affinity (ingress Cilium)

## Déploiement

```bash
# 1. Copier et remplir les fichiers de config
cp values-prod.yaml.example values-prod.yaml
cp values-staging.yaml.example values-staging.yaml
# Éditer avec vos vraies valeurs

# 2. Créer les namespaces
kubectl create namespace odoo-prod
kubectl create namespace odoo-staging

# 3. Installer
helm install odoo-prod ./odoo-chart -f values-prod.yaml
helm install odoo-staging ./odoo-chart -f values-staging.yaml
```

## Rolling Update

```bash
helm upgrade odoo-prod ./odoo-chart -f values-prod.yaml --set image.tag=v2
helm rollback odoo-prod 1   # rollback si problème
helm history odoo-prod      # historique des versions
```
