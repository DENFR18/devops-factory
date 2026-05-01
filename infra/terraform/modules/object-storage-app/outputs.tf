output "bucket_names" {
  description = "Map of bucket key → bucket name for all created buckets"
  value       = { for k, v in scaleway_object_bucket.app : k => v.name }
}

output "bucket_endpoints" {
  description = "Map of bucket key → S3-compatible endpoint URL"
  value       = { for k, v in scaleway_object_bucket.app : k => v.endpoint }
}
