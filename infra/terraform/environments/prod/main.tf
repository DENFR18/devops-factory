locals {
  env          = "prod"
  project_name = "devops-factory"
  region       = "fr-par"
  zone         = "fr-par-1"
}

module "networking" {
  source = "../../modules/networking"

  project_name        = local.project_name
  env                 = local.env
  region              = local.region
  private_subnet_cidr = var.private_subnet_cidr
  gateway_type        = "VPC-GW-M"
}

module "cluster" {
  source = "../../modules/kapsule-cluster"

  project_name       = local.project_name
  env                = local.env
  region             = local.region
  kubernetes_version = var.kubernetes_version
  private_network_id = module.networking.private_network_id
  prevent_destroy    = true
}

module "pool_default" {
  source = "../../modules/kapsule-pool"

  cluster_id  = module.cluster.cluster_id
  pool_name   = "default"
  node_type   = var.node_type
  size        = var.node_count
  min_size    = var.autoscaling_min
  max_size    = var.autoscaling_max
  env         = local.env
  region      = local.region
  zone        = local.zone
  cost_center = var.cost_center
  owner       = var.owner
}

module "registry" {
  source = "../../modules/container-registry"

  project_name = local.project_name
  env          = local.env
  region       = local.region
}

module "object_storage" {
  source = "../../modules/object-storage-app"

  project_name = local.project_name
  env          = local.env
  region       = local.region
  buckets      = var.app_buckets
}

module "iam" {
  source = "../../modules/iam"
  count  = var.enable_pipeline_iam ? 1 : 0

  project_name    = local.project_name
  env             = local.env
  project_id      = var.project_id
  prevent_destroy = true
}
