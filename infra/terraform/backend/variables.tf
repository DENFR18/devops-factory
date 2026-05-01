variable "env" {
  type        = string
  description = "Target environment (dev or prod)"
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

variable "zone" {
  type        = string
  description = "Scaleway availability zone"
  default     = "fr-par-1"
}

variable "project_id" {
  type        = string
  description = "Scaleway project ID (UUID)"
}
