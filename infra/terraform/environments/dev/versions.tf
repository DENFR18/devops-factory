terraform {
  required_version = ">= 1.7"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.43"
    }
  }
}

provider "scaleway" {
  region          = "fr-par"
  zone            = "fr-par-1"
  project_id      = var.project_id
  # organization_id read from SCW_DEFAULT_ORGANIZATION_ID env var by the SDK
  # Credentials via SCW_ACCESS_KEY / SCW_SECRET_KEY (GitHub Secrets)
}
