# Module: kapsule-pool

Creates a Kapsule node pool with autoscaling and autohealing enabled.

## Design decisions

- **upgrade_policy**: `max_unavailable=1, max_surge=0` — rolling upgrade, never adds extra nodes (cost-conscious).
- **autohealing=true**: unhealthy nodes are replaced automatically.
- Cost center and owner tags are mandatory for FinOps visibility.

## Usage

```hcl
module "pool_default" {
  source = "../../modules/kapsule-pool"

  cluster_id  = module.cluster.cluster_id
  pool_name   = "default"
  node_type   = "GP1-S"
  size        = 3
  min_size    = 3
  max_size    = 6
  env         = "prod"
  region      = "fr-par"
  zone        = "fr-par-1"
  cost_center = "platform-prod"
  owner       = "devops-team"
}
```

## Outputs

| Output | Description |
|---|---|
| `pool_id` | Node pool identifier |
| `nodes_count` | Current node count (after autoscaling) |
| `node_type` | Instance type in use |
