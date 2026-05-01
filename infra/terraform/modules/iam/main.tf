locals {
  name_prefix = "${var.project_name}-${var.env}"
}

resource "scaleway_iam_application" "gitlab_ci" {
  name        = "${local.name_prefix}-gitlab-ci"
  description = "GitLab CI service account — ${var.env} pipelines only"
}

resource "scaleway_iam_api_key" "gitlab_ci" {
  application_id = scaleway_iam_application.gitlab_ci.id
  description    = "GitLab CI API key — ${var.env} (managed by Terraform)"
}

# Minimum viable permissions for GitLab CI:
#   - Kapsule: deploy and manage workloads
#   - Container Registry: push/pull images
#   - Object Storage: read/write plans and artifacts
#
# IMPORTANT: verify permission set names against the Scaleway IAM catalog
# at https://console.scaleway.com/iam/policies before first apply.
resource "scaleway_iam_policy" "gitlab_ci" {
  name           = "${local.name_prefix}-gitlab-ci-policy"
  description    = "Minimal policy for GitLab CI pipelines — ${var.env}"
  application_id = scaleway_iam_application.gitlab_ci.id

  rule {
    project_ids          = [var.project_id]
    permission_set_names = ["KubernetesFullAccess"]
  }

  rule {
    project_ids          = [var.project_id]
    permission_set_names = ["RegistryFullAccess"]
  }

  rule {
    project_ids          = [var.project_id]
    permission_set_names = ["ObjectStorageFullAccess"]
  }
}

resource "terraform_data" "destroy_guard" {
  count = var.prevent_destroy ? 1 : 0

  lifecycle {
    prevent_destroy = true
  }
}
