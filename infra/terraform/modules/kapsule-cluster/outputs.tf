output "cluster_id" {
  description = "Kapsule cluster ID"
  value       = scaleway_k8s_cluster.main.id
}

output "cluster_name" {
  description = "Kapsule cluster name"
  value       = scaleway_k8s_cluster.main.name
}

output "apiserver_url" {
  description = "Kubernetes API server URL"
  value       = scaleway_k8s_cluster.main.apiserver_url
}

output "kubeconfig" {
  description = "Raw kubeconfig content — store in GitLab CI variable KUBECONFIG, never in git"
  value       = scaleway_k8s_cluster.main.kubeconfig[0].config_file
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (base64)"
  value       = scaleway_k8s_cluster.main.kubeconfig[0].cluster_ca_certificate
  sensitive   = true
}
