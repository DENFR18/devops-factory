# Module: iam

Creates a dedicated Scaleway IAM Application (service account) for GitLab CI pipelines with a scoped API key and minimal policy.

## Security model

- One application per environment — dev and prod CI pipelines use different keys.
- Policy rules are project-scoped (no org-wide permissions).
- API key is marked `sensitive = true` — never appears in plan output.

## Post-apply steps

1. Run `terraform output -raw gitlab_ci_access_key` and `terraform output -raw gitlab_ci_secret_key`.
2. Store both values as **protected and masked** CI/CD variables in GitLab:
   - `SCW_ACCESS_KEY`
   - `SCW_SECRET_KEY`
3. Verify the permission sets in the Scaleway console. The names used here (`KubernetesFullAccess`, `RegistryFullAccess`, `ObjectStorageFullAccess`) must match those in your organization's IAM catalog.

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"

  project_name    = "devops-factory"
  env             = "prod"
  project_id      = var.project_id
  prevent_destroy = true
}
```

## Outputs

| Output | Description |
|---|---|
| `gitlab_ci_access_key` | **Sensitive** — SCW_ACCESS_KEY for GitLab CI |
| `gitlab_ci_secret_key` | **Sensitive** — SCW_SECRET_KEY for GitLab CI |
| `gitlab_ci_application_id` | Application ID for audit |
