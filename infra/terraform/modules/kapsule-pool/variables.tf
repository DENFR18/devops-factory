variable "cluster_id" {
  type        = string
  description = "ID of the Kapsule cluster (from kapsule-cluster module)"
}

variable "pool_name" {
  type        = string
  description = "Name of the node pool"
}

variable "node_type" {
  type        = string
  description = "Node instance type — e.g. DEV1-M (dev), GP1-S (prod)"
}

variable "size" {
  type        = number
  description = "Desired number of nodes (initial value, autoscaler may override)"
}

variable "min_size" {
  type        = number
  description = "Minimum number of nodes for the autoscaler"
  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1."
  }
}

variable "max_size" {
  type        = number
  description = "Maximum number of nodes for the autoscaler"
  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size must be >= min_size."
  }
}

variable "env" {
  type        = string
  description = "Environment name — used for tagging"
}

variable "region" {
  type        = string
  description = "Scaleway region"
  default     = "fr-par"
}

variable "zone" {
  type        = string
  description = "Scaleway zone for the node pool"
  default     = "fr-par-1"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag for FinOps reporting"
}

variable "owner" {
  type        = string
  description = "Owner tag for FinOps reporting"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged into pool tags"
  default     = {}
}
