variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "4dd0789e-e199-44d7-bed6-b6a8af57d141"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "swedencentral"
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "devops-factory"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "aks_min_node_count" {
  description = "Minimum number of AKS nodes (autoscaler)"
  type        = number
  default     = 1
}

variable "aks_max_node_count" {
  description = "Maximum number of AKS nodes (autoscaler)"
  type        = number
  default     = 3
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.32"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}
