# Module: kapsule-cluster

Provisions a Scaleway Kapsule (managed Kubernetes) cluster with Cilium CNI, auto-upgrade, and optional destroy protection.

## Design decisions

- **Cilium CNI**: native NetworkPolicy support + Hubble observability — required for tenant isolation.
- **admission_plugins**: `PodSecurity` + `NodeRestriction` enabled by default.
- **delete_additional_resources = false**: prevents silent deletion of attached LBs/volumes on destroy. Clean them up manually first.
- **prevent_destroy**: uses a `terraform_data` sentinel because Terraform lifecycle blocks cannot be conditional. Set `true` for prod.

## Usage

```hcl
module "cluster" {
  source = "../../modules/kapsule-cluster"

  project_name       = "devops-factory"
  env                = "prod"
  region             = "fr-par"
  kubernetes_version = "1.31"
  private_network_id = module.networking.private_network_id
  prevent_destroy    = true
}
```

## Outputs

| Output | Description |
|---|---|
| `cluster_id` | Pass to `kapsule-pool` module |
| `apiserver_url` | API server URL |
| `kubeconfig` | **Sensitive** — store as masked GitLab CI variable |
| `cluster_ca_certificate` | **Sensitive** — CA cert for in-cluster auth |
