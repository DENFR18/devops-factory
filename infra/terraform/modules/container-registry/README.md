# Module: container-registry

Creates a private Scaleway Container Registry (SCR) namespace.

## Usage

```hcl
module "registry" {
  source = "../../modules/container-registry"

  project_name = "devops-factory"
  env          = "prod"
  region       = "fr-par"
}
```

## Outputs

| Output | Description |
|---|---|
| `registry_endpoint` | Image prefix for Docker push/pull |
| `registry_namespace_id` | Namespace ID |
| `registry_namespace_name` | Namespace name |

## Image naming convention

```
rg.fr-par.scw.cloud/devops-factory-prod/<service>@sha256:<digest>
```

Tag by digest for ArgoCD, ingress-nginx, and cert-manager. Use semver tags for tenant micro-services.
