locals {
  base_tags = [
    "env:${var.env}",
    "managed-by:terraform",
    "cost-center:${var.cost_center}",
    "owner:${var.owner}",
  ]
  extra_tags = [for k, v in var.tags : "${k}:${v}"]
  all_tags   = concat(local.base_tags, local.extra_tags)
}

resource "scaleway_k8s_pool" "main" {
  cluster_id  = var.cluster_id
  name        = var.pool_name
  node_type   = var.node_type
  size        = var.size
  min_size    = var.min_size
  max_size    = var.max_size
  autoscaling = true
  autohealing = true
  region      = var.region
  zone        = var.zone

  upgrade_policy {
    max_unavailable = 1
    max_surge       = 0
  }

  tags = local.all_tags
}
