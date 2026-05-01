# DevOps Factory

Usine logicielle DevSecOps multi-tenant déployée sur **Scaleway Kapsule** (fr-par).
Pipeline GitLab CI/CD, GitOps via ArgoCD app-of-apps, IaC Terraform.

---

## Quickstart from zero

> No local CLI tools required. Everything runs in the pipeline.

### Prerequisites

- A GitLab account with access to this repository.
- A [Scaleway](https://console.scaleway.com) account with a Project created.

### Steps

**1. Fork or clone the repo**

```bash
git clone https://gitlab.com/<your-namespace>/devops-factory.git
cd devops-factory
```

**2. Create a Scaleway project and IAM API key**

1. Log in to [console.scaleway.com](https://console.scaleway.com).
2. Create a **Project** (or use an existing one) — note the **Project ID** (UUID).
3. Go to **IAM → API Keys** and generate a key with at minimum:
   - `ObjectStorageBucketsWrite`
   - `KapsuleFullAccess`
   - `RegistryFullAccess`

**3. Add the 3 CI/CD variables in GitLab**

Navigate to **Settings → CI/CD → Variables** and add:

| Variable | Protected | Masked |
|---|:---:|:---:|
| `SCW_ACCESS_KEY` | ✅ | ✅ |
| `SCW_SECRET_KEY` | ✅ | ✅ |
| `SCW_DEFAULT_PROJECT_ID` | ✅ | ❌ |

See [`docs/runbooks/gitlab-ci-variables.md`](docs/runbooks/gitlab-ci-variables.md) for step-by-step screenshots and the key rotation procedure.

**4. Bootstrap the Terraform state buckets (once)**

Push to `main` (or open a MR targeting `main`), then in **CI/CD → Pipelines**:

- Find the `bootstrap` stage → click the ▶ button on `bootstrap-state-buckets`.

This creates `devops-factory-tfstate-dev` and `devops-factory-tfstate-prod` on Scaleway Object Storage with versioning and 90-day lifecycle expiry. The job is idempotent — re-running it on an already configured project is safe.

**5. Open a MR with a Terraform change**

The pipeline automatically runs:
- `terraform fmt` → `terraform validate` → `tflint` (validate stage)
- `checkov` security scan (security stage)
- `terraform-plan-dev` with GitLab Terraform report in the MR (plan stage)

**6. Merge the MR → apply to dev**

After merge to `main` or `develop`, trigger `terraform-apply-dev` manually from the pipeline UI.

**7. Done.**

The Kapsule cluster, networking, and IAM are provisioned. ArgoCD bootstrapping is the next step (see `k8s/argocd/`).

---

## Architecture overview

| Dimension | Detail |
|---|---|
| Cloud | Scaleway fr-par / fr-par-1 |
| Kubernetes | Kapsule 1.31 |
| GitOps | ArgoCD 2.x — app-of-apps pattern |
| Tenants | alpha · beta · gamma |
| IaC | Terraform >= 1.7, S3 backend on Scaleway |
| CI/CD | GitLab CI — `include:` + `extends:` pattern |
| Secrets | Sealed Secrets (no plaintext secrets in repo) |
| Ingress | NGINX Ingress + cert-manager + Let's Encrypt |
| Observability | kube-prometheus-stack |
| Security | Trivy · Checkov · SonarCloud · tflint |

## Repository structure

```
.gitlab-ci.yml             # entry-point: includes infra + apps sub-pipelines
.gitlab/ci/
  infra.gitlab-ci.yml      # Terraform bootstrap → validate → security → plan → apply
  apps.gitlab-ci.yml       # build → scan → deploy (ArgoCD sync)
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
    gitlab-ci-variables.md # variable setup, rotation, onboarding
```

## Pipeline stages

```
bootstrap → validate → security → plan → build → scan → apply → deploy
```

| Stage | Jobs |
|---|---|
| bootstrap | `bootstrap-state-buckets` (manual, main only, one-time) |
| validate | `terraform-fmt`, `terraform-validate-dev/prod`, `tflint` |
| security | `checkov` (fails on HIGH/CRITICAL, warns on MEDIUM) |
| plan | `terraform-plan-dev/prod` — GitLab Terraform report in MR |
| build | _(apps pipeline — container builds)_ |
| scan | _(apps pipeline — Trivy image scan)_ |
| apply | `terraform-apply-dev/prod` (manual), `terraform-destroy-*` (manual) |
| deploy | _(apps pipeline — ArgoCD sync)_ |

## Branch workflow

| Branch | Role | Apply allowed |
|---|---|---|
| `main` | Production source of truth | dev ✅ prod ✅ (both manual) |
| `develop` | Continuous integration | dev ✅ (manual) |
| `feat/*` `fix/*` | Feature/fix branches | plan + scan only |

MRs to `main` trigger the full pipeline. Auto-merge is disabled — a human review is required.
