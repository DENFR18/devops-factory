# DevOps Factory — Contexte Claude Code

## 🏗️ Projet

Usine logicielle **DevSecOps multi-tenant** déployée sur **Scaleway Kapsule** (fr-par).
Projet collaboratif en binôme, pipeline GitHub Actions, GitOps via ArgoCD app-of-apps.

| Dimension | Détail |
|---|---|
| Cloud | Scaleway (fr-par / fr-par-1) |
| Orchestration | Kubernetes 1.31 sur Kapsule |
| GitOps | ArgoCD 2.x — pattern app-of-apps |
| Tenants | 3 micro-services : alpha, beta, gamma |
| Namespaces | 8 namespaces isolés (1 par tenant + infra) |
| IaC | Terraform >= 1.7 |
| CI/CD | GitHub Actions avec workflows réutilisables et `uses:` |
| Secrets | Sealed Secrets (jamais de secret en clair) |
| Sécurité | Trivy, Checkov, SonarCloud, tflint |
| Ingress | NGINX Ingress + cert-manager + Let's Encrypt |
| Observabilité | kube-prometheus-stack |

---

## 📁 Structure du repo

```
infra/
  terraform/
    modules/          # modules réutilisables
    environments/
      dev/
      prod/
k8s/
  base/               # manifests partagés
  tenants/
    alpha/
    beta/
    gamma/
  argocd/             # app-of-apps
.github/
  workflows/          # workflows GitHub Actions réutilisables
```

---

## 📐 Conventions code

### Terraform

- Modules dans `infra/terraform/modules/`, environments dans `infra/terraform/environments/{dev,prod}/`
- Nommage : **snake_case** pour toutes les ressources, variables, outputs
- `terraform fmt` systématique avant tout commit
- Providers **pinnés** à une version exacte ou contrainte `~>` dans `required_providers`
- Backend : **Object Storage Scaleway** (jamais de state local committé)
- Toujours inclure `description` sur chaque variable et output
- Pas de `terraform apply` sans plan validé et approuvé

### Kubernetes

- Fichiers YAML en **kebab-case** (`my-deployment.yaml`)
- Labels **obligatoires** sur toutes les ressources :
  ```yaml
  labels:
    app.kubernetes.io/name: <name>
    app.kubernetes.io/part-of: <service>
    tenant: <alpha|beta|gamma>
  ```
- `resources.requests` et `resources.limits` **toujours définis** sur chaque container
- Pas de `kubectl apply` manuel hors phase de bootstrap initiale
- Pas de `helm install` direct une fois ArgoCD bootstrappé

### GitHub Actions

- Jobs réutilisables via `uses:` (workflows dans `.github/workflows/`)
- Déclencheurs explicites (`on:`) en tête de chaque workflow : `push`, `pull_request`, `workflow_call`
- `environment: production` avec approbation manuelle obligatoire pour tout job `apply` ou `deploy` ciblant **prod**
- Conditionnels `if:` sur les jobs : `apply` sur `github.ref == 'refs/heads/main'` uniquement, `plan` sur toutes les PRs
- Variables Scaleway exclusivement via **GitHub Secrets** (repo ou environnement), jamais en dur

### Commits

Format **Conventional Commits** strict :

```
feat(infra): add Kapsule node pool for gamma tenant
fix(ci): correct Trivy scan on alpine images
chore(k8s): bump ArgoCD to 2.12.1 by digest
docs(readme): update bootstrap steps
```

Scopes courants : `infra`, `ci`, `k8s`, `argocd`, `terraform`, `secrets`, `monitoring`, `tenant`

---

## 🔒 Règles sécurité (non négociables)

### Secrets
- **Aucun secret en clair** dans les manifests ou le code — Sealed Secrets obligatoire
- Variables Scaleway (`SCW_ACCESS_KEY`, `SCW_SECRET_KEY`, `SCW_DEFAULT_PROJECT_ID`, `SCW_DEFAULT_REGION=fr-par`, `SCW_DEFAULT_ZONE=fr-par-1`) : uniquement via **GitHub Secrets** (repo ou environnement), jamais en dur

### Réseau
- Pas de `0.0.0.0/0` dans les Security Groups ou NetworkPolicies sans justification documentée dans le code
- NetworkPolicies **deny-all par défaut**, ouvertures explicites et minimales

### Conteneurs
- Exécution **non-root** (`runAsNonRoot: true`, `runAsUser` != 0)
- `readOnlyRootFilesystem: true` partout où c'est possible
- `seccompProfile: RuntimeDefault` (ou plus restrictif)
- Pas de `privileged: true` sauf besoin absolu documenté
- `allowPrivilegeEscalation: false`

### Images Docker
- Tag par **digest** (`@sha256:...`) pour les composants critiques (ArgoCD, ingress-nginx, cert-manager)
- Pas de tag `latest` — jamais
- Images scannées par Trivy avant déploiement

### IaC
- Checkov sur tous les plans Terraform avant apply
- tflint sur tous les modules
- SonarCloud sur le code applicatif des micro-services

---

## 🔀 Workflow Git

| Branche | Rôle | Protection |
|---|---|---|
| `main` | Production — source de vérité GitOps | Protégée, PR obligatoire, review requise |
| `develop` | Intégration continue | PR recommandée |
| `feat/<scope>` | Nouvelle fonctionnalité | — |
| `fix/<scope>` | Correction | — |

- **Pas d'auto-merge** sans review humaine
- PR vers `main` déclenche workflow complet (plan + scan + review)
- PR vers `develop` : plan + scan (sans apply)
- Rebase plutôt que merge commit sur les feature branches

---

## 🚫 Anti-patterns

- `kubectl apply` manuel hors bootstrap → utiliser ArgoCD
- `helm install` direct hors ArgoCD une fois bootstrappé
- Tag `latest` sur n'importe quelle image
- `terraform apply` sans plan validé
- PR auto-merge sans review
- Secrets en clair dans manifests, `.env`, ou historique git
- State Terraform local committé
- `0.0.0.0/0` non justifié dans les règles réseau
- Variables Scaleway hardcodées dans le code

---

## 🛠️ Stack technique de référence

| Composant | Version / Config |
|---|---|
| Scaleway Kapsule | fr-par, fr-par-1 |
| Terraform | >= 1.7 |
| Kubernetes | 1.31 |
| ArgoCD | 2.x (app-of-apps) |
| NGINX Ingress | tag digest sur prod |
| cert-manager | Let's Encrypt (prod + staging issuer) |
| Sealed Secrets | controller in-cluster |
| kube-prometheus-stack | Prometheus + Grafana + Alertmanager |
| Trivy | scan images + manifests |
| Checkov | scan Terraform + Kubernetes |
| SonarCloud | analyse statique code applicatif |
| tflint | lint Terraform |
