output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.acr.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID (pour Prometheus/Grafana)"
  value       = azurerm_log_analytics_workspace.law.id
}

output "namespace_names" {
  description = "Liste des namespaces créés (pour Gwen — ServiceMonitors)"
  value       = [for ns in kubernetes_namespace.stacks : ns.metadata[0].name]
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "kubeconfig_raw" {
  description = "Raw kubeconfig (base64) — use as KUBE_CONFIG in GitLab CI"
  value       = base64encode(azurerm_kubernetes_cluster.aks.kube_config_raw)
  sensitive   = true
}
