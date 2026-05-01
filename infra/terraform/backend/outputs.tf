output "tfstate_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = scaleway_object_bucket.tfstate.name
}

output "tfstate_s3_endpoint" {
  description = "S3-compatible endpoint — use in backend.tf of each environment"
  value       = "https://s3.${var.region}.scw.cloud"
}

output "tfplans_bucket_name" {
  description = "Name of the Terraform plans bucket"
  value       = scaleway_object_bucket.tfplans.name
}
