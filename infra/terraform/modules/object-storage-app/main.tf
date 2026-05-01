resource "scaleway_object_bucket" "app" {
  for_each = { for b in var.buckets : b.name => b }

  name   = each.value.name
  region = var.region
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "archive-and-expire"
    enabled = true

    transition {
      days          = each.value.cold_after
      storage_class = "GLACIER"
    }

    expiration {
      days = each.value.expire_after
    }
  }

  tags = {
    env           = var.env
    "managed-by"  = "terraform"
    project       = var.project_name
    purpose       = each.value.purpose
    "cost-center" = "platform"
  }
}
