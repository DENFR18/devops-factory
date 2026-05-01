resource "scaleway_registry_namespace" "main" {
  name        = "${var.project_name}-${var.env}"
  description = var.description != "" ? var.description : "Container registry — ${var.project_name} ${var.env}"
  is_public   = false
  region      = var.region
}
