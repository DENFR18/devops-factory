output "gitlab_ci_access_key" {
  description = "Scaleway access key for GitLab CI — store as SCW_ACCESS_KEY in GitLab CI/CD (protected + masked)"
  value       = scaleway_iam_api_key.gitlab_ci.access_key
  sensitive   = true
}

output "gitlab_ci_secret_key" {
  description = "Scaleway secret key for GitLab CI — store as SCW_SECRET_KEY in GitLab CI/CD (protected + masked)"
  value       = scaleway_iam_api_key.gitlab_ci.secret_key
  sensitive   = true
}

output "gitlab_ci_application_id" {
  description = "IAM Application ID — use in Scaleway console to audit API key usage"
  value       = scaleway_iam_application.gitlab_ci.id
}
