output "registry_endpoint" {
  description = "Registry endpoint — use as image prefix (e.g. rg.fr-par.scw.cloud/<namespace>/<image>:<tag>)"
  value       = scaleway_registry_namespace.main.endpoint
}

output "registry_namespace_id" {
  description = "Registry namespace ID"
  value       = scaleway_registry_namespace.main.id
}

output "registry_namespace_name" {
  description = "Registry namespace name"
  value       = scaleway_registry_namespace.main.name
}
