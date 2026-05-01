variable "project_id" {
  type        = string
  description = "Scaleway project ID (UUID)"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for the private network"
  default     = "10.0.0.0/20"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the Kapsule cluster"
  default     = "1.31"
}

variable "node_type" {
  type        = string
  description = "Node instance type"
  default     = "DEV1-M"
}

variable "node_count" {
  type        = number
  description = "Initial number of nodes"
  default     = 2
}

variable "autoscaling_min" {
  type        = number
  description = "Minimum nodes for autoscaler"
  default     = 1
}

variable "autoscaling_max" {
  type        = number
  description = "Maximum nodes for autoscaler"
  default     = 3
}

variable "cost_center" {
  type        = string
  description = "Cost center for FinOps tagging"
  default     = "platform-dev"
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
      name         = "devops-factory-logs-dev"
      purpose      = "logs"
      cold_after   = 30
      expire_after = 365
    },
    {
      name         = "devops-factory-artifacts-dev"
      purpose      = "artifacts"
      cold_after   = 30
      expire_after = 365
    },
  ]
}
