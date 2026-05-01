# Module: object-storage-app

Creates private application buckets on Scaleway Object Storage with versioning enabled and a two-phase lifecycle rule (STANDARD → GLACIER transition, then expiration).

## Usage

```hcl
module "object_storage" {
  source = "../../modules/object-storage-app"

  project_name = "devops-factory"
  env          = "prod"
  region       = "fr-par"

  buckets = [
    {
      name         = "devops-factory-logs-prod"
      purpose      = "logs"
      cold_after   = 30
      expire_after = 365
    },
    {
      name         = "devops-factory-artifacts-prod"
      purpose      = "artifacts"
      cold_after   = 30
      expire_after = 365
    },
  ]
}
```

## Lifecycle

| Phase | Day | Action |
|---|---|---|
| Active | 0 → `cold_after` | STANDARD storage |
| Archive | `cold_after` → `expire_after` | GLACIER (cold) storage |
| Expiry | `expire_after` | Object deleted |

## Outputs

| Output | Description |
|---|---|
| `bucket_names` | Map of name → bucket name |
| `bucket_endpoints` | Map of name → S3 endpoint URL |
