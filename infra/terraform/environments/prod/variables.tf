variable "project_id" {
  type        = string
  description = "Scaleway project ID (UUID)"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for the private network"
  default     = "10.1.0.0/20"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the Kapsule cluster"
  default     = "1.32"
}

variable "node_type" {
  type        = string
  description = "Node instance type"
  default     = "GP1-S"
}

variable "node_count" {
  type        = number
  description = "Initial number of nodes"
  default     = 3
}

variable "autoscaling_min" {
  type        = number
  description = "Minimum nodes for autoscaler"
  default     = 3
}

variable "autoscaling_max" {
  type        = number
  description = "Maximum nodes for autoscaler"
  default     = 6
}

variable "cost_center" {
  type        = string
  description = "Cost center for FinOps tagging"
  default     = "platform-prod"
}

variable "owner" {
  type        = string
  description = "Owner for FinOps tagging"
  default     = "devops-team"
}

variable "app_buckets" {
  type = list(object({
    name         = string
    purpose      = string
    cold_after   = number
    expire_after = number
  }))
  description = "Application buckets with lifecycle rules"
  default = [
    {
      name         = "devops-factory-logs-prod"
      purpose      = "logs"
      cold_after   = 90
      expire_after = 730
    },
    {
      name         = "devops-factory-artifacts-prod"
      purpose      = "artifacts"
      cold_after   = 90
      expire_after = 730
    },
    {
      name         = "devops-factory-exports-prod"
      purpose      = "tenant-exports"
      cold_after   = 90
      expire_after = 1095
    },
  ]
}
