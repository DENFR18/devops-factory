resource "scaleway_object_bucket" "tfstate" {
  name   = "devops-factory-tfstate-${var.env}"
  region = var.region
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    env         = var.env
    "managed-by" = "terraform"
    purpose     = "terraform-state"
    "cost-center" = "platform"
  }
}

resource "scaleway_object_bucket" "tfplans" {
  name   = "devops-factory-tfplans-${var.env}"
  region = var.region
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    env         = var.env
    "managed-by" = "terraform"
    purpose     = "terraform-plans"
    "cost-center" = "platform"
  }
}
