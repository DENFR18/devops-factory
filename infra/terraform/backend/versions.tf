terraform {
  required_version = ">= 1.7"
  # Local backend intentional — this config creates the remote state buckets.
  # Commit the resulting terraform.tfstate once after bootstrap, then ignore it.

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.43"
    }
  }
}

provider "scaleway" {
  region     = var.region
  zone       = var.zone
  project_id = var.project_id
  # Credentials via SCW_ACCESS_KEY / SCW_SECRET_KEY env vars
}
