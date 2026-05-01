locals {
  cluster_name = "${var.project_name}-${var.env}"
  base_tags = [
    "env:${var.env}",
    "managed-by:terraform",
    "project:${var.project_name}",
  ]
  extra_tags = [for k, v in var.tags : "${k}:${v}"]
  all_tags   = concat(local.base_tags, local.extra_tags)
}

resource "scaleway_k8s_cluster" "main" {
  name               = local.cluster_name
  description        = var.description != "" ? var.description : "Kapsule cluster — ${var.project_name} ${var.env}"
  version            = var.kubernetes_version
  cni                = "cilium"
  region             = var.region
  private_network_id = var.private_network_id

  auto_upgrade {
    enable                        = true
    maintenance_window_day        = var.maintenance_window_day
    maintenance_window_start_hour = var.maintenance_window_start_hour
  }

  admission_plugins = var.admission_plugins

  # Deleting the cluster will NOT automatically delete attached LBs/volumes.
  # Clean up manually before destroy to avoid orphaned billable resources.
  delete_additional_resources = false

  tags = local.all_tags
}

# Prevents accidental destroy on prod. Terraform does not support dynamic lifecycle
# blocks, so we use a sentinel resource — attempting to destroy it will fail the plan.
resource "terraform_data" "destroy_guard" {
  count = var.prevent_destroy ? 1 : 0

  lifecycle {
    prevent_destroy = true
  }
}
