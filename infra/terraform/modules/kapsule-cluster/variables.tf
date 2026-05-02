variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "env" {
  type        = string
  description = "Environment name"
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "env must be dev or prod."
  }
}

variable "region" {
  type        = string
  description = "Scaleway region"
  default     = "fr-par"
  validation {
    condition     = contains(["fr-par", "nl-ams", "pl-waw"], var.region)
    error_message = "region must be one of: fr-par, nl-ams, pl-waw."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version (e.g. 1.31)"
  default     = "1.31"
}

variable "private_network_id" {
  type        = string
  description = "Private network ID to attach the cluster to (from networking module)"
}

variable "description" {
  type        = string
  description = "Human-readable cluster description"
  default     = ""
}

variable "admission_plugins" {
  type        = list(string)
  description = "Kubernetes admission plugins to enable"
  default     = null
}

variable "maintenance_window_day" {
  type        = string
  description = "Day of week for auto-upgrade maintenance window"
  default     = "sunday"
  validation {
    condition     = contains(["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "any"], var.maintenance_window_day)
    error_message = "Must be a valid day name or 'any'."
  }
}

variable "maintenance_window_start_hour" {
  type        = number
  description = "Hour (UTC, 0-23) to start the maintenance window"
  default     = 2
  validation {
    condition     = var.maintenance_window_start_hour >= 0 && var.maintenance_window_start_hour <= 23
    error_message = "maintenance_window_start_hour must be between 0 and 23."
  }
}

variable "prevent_destroy" {
  type        = bool
  description = "Create a destroy guard resource to prevent accidental cluster deletion (set true for prod)"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged into cluster tags"
  default     = {}
}
