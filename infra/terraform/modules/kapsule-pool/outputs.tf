output "pool_id" {
  description = "ID of the node pool"
  value       = scaleway_k8s_pool.main.id
}

output "nodes_count" {
  description = "Current number of nodes in the pool"
  value       = scaleway_k8s_pool.main.current_size
}

output "node_type" {
  description = "Instance type used by this pool"
  value       = scaleway_k8s_pool.main.node_type
}
