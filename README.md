# DevOps Factory

Usine logicielle DevSecOps multi-tenant déployée sur **Scaleway Kapsule** (fr-par).
Pipeline GitHub Actions, GitOps via ArgoCD app-of-apps, IaC Terraform.

---

## Quickstart from zero

> No local CLI tools required. Everything runs in the pipeline.

**1. Fork the repo**

```bash
git clone https://github.com/<your-namespace>/devops-factory.git
cd devops-factory
```

**2. Create a Scaleway project and IAM API key**

1. Log in to [console.scaleway.com](https://console.scaleway.com).
2. Create a **Project** (or use an existing one) — note the **Project ID** (UUID).
3. Go to **IAM → API Keys** and generate a key with at minimum:
   - `ObjectStorageBucketsWrite`
   - `KapsuleFullAccess`
   - `RegistryFullAccess`

**3. Add the 3 secrets in GitHub Settings → Secrets → Actions**

Navigate to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|---|---|
| `SCW_ACCESS_KEY` | Scaleway IAM access key |
| `SCW_SECRET_KEY` | Scaleway IAM secret key |
| `SCW_DEFAULT_PROJECT_ID` | Scaleway project UUID |

That's all a human needs to set manually. See [`docs/runbooks/github-actions-secrets.md`](docs/runbooks/github-actions-secrets.md) for the full procedure including environment setup, key rotation, and collaborator onboarding.

**4. Run the workflow "Bootstrap — State Buckets" (once)**

Go to **Actions → Bootstrap — State Buckets → Run workflow**.

This creates `devops-factory-tfstate-dev` and `devops-factory-tfstate-prod` on Scaleway Object Storage with versioning and 90-day lifecycle expiry. The workflow is idempotent — safe to re-run.

**5. Open a PR with a Terraform change**

The `infra.yml` workflow triggers automatically and runs:
- `terraform fmt` + `terraform validate` (both envs)
- `tflint` (informational)
- `checkov` security scan → results in GitHub Security tab
- `terraform plan` for dev (and prod on PRs to `main`) → summary posted as PR comment

**6. Merge → approve the apply → cluster up in ~10 min**

After merge to `main` or `develop`, the `terraform-apply-dev` job waits for
approval in the **GitHub Environment `dev`**. Go to **Actions → the run → Review deployments** and approve.

**7. That's it. No local CLI required.**

The Kapsule cluster, networking, and IAM are provisioned. ArgoCD bootstrapping is the next step (see `k8s/argocd/`).

---

## Day-to-day operations

| Action | Workflow | Déclencheur |
|---|---|---|
| Créer les buckets state (1 seule fois) | Bootstrap — State Buckets | Manuel |
| Déployer l'infra | Deploy Infrastructure | Manuel, choix env |
| Détruire l'infra (fin de session) | Destroy Infrastructure | Manuel, confirmation `destroy` |
| Valider un changement Terraform | Infrastructure — Terraform | Auto sur PR |

---

## Architecture overview

| Dimension | Detail |
|---|---|
| Cloud | Scaleway fr-par / fr-par-1 |
| Kubernetes | Kapsule 1.31 |
| GitOps | ArgoCD 2.x — app-of-apps pattern |
| Tenants | alpha · beta · gamma |
| IaC | Terraform >= 1.7, S3 backend on Scaleway |
| CI/CD | GitHub Actions — reusable workflows with `uses:` |
| Secrets | Sealed Secrets (no plaintext secrets in repo) |
| Ingress | NGINX Ingress + cert-manager + Let's Encrypt |
| Observability | kube-prometheus-stack |
| Security | Trivy · Checkov · SonarCloud · tflint |

## Repository structure

```
.github/
  workflows/
    bootstrap.yml          # one-time: create Scaleway state buckets
    infra.yml              # Terraform: fmt → validate → tflint → checkov → plan → apply
    apps.yml               # build → scan → deploy (ArgoCD sync) — coming soon
infra/
  terraform/
    modules/               # reusable modules (kapsule-cluster, networking, iam, …)
    environments/
      dev/                 # dev cluster config
      prod/                # prod cluster config
k8s/
  base/                    # shared manifests
  tenants/alpha|beta|gamma # per-tenant workloads
  argocd/                  # app-of-apps bootstrap
docs/
  runbooks/
    github-actions-secrets.md  # secrets, environments, rotation, onboarding
```

## Pipeline stages

```
bootstrap → validate → security → plan → apply
                                          ↑
                              Requires GitHub Environment approval
```

| Workflow | Jobs |
|---|---|
| `bootstrap.yml` | `create-state-buckets` (manual, one-time, idempotent) |
| `infra.yml` | `terraform-fmt`, `terraform-validate-dev/prod`, `tflint`, `checkov` |
| `infra.yml` | `terraform-plan-dev/prod` — plan summary posted as PR comment |
| `infra.yml` | `terraform-apply-dev/prod` — requires Environment approval |
| `infra.yml` | `terraform-destroy-dev` — `workflow_dispatch` with confirm="destroy" only |
| `apps.yml` | _(coming soon — container build, Trivy scan, ArgoCD sync)_ |

## Branch workflow

| Branch | Role | Apply allowed |
|---|---|---|
| `main` | Production source of truth | dev ✅ prod ✅ (both require approval) |
| `develop` | Continuous integration | dev ✅ (requires approval) |
| `feat/*` `fix/*` | Feature/fix branches | plan + scan only |

PRs to `main` trigger the full pipeline. Auto-merge is disabled — a human review is required.
