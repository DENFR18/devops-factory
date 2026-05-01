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

variable "description" {
  type        = string
  description = "Registry namespace description"
  default     = ""
}
