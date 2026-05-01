variable "project_name" {
  type        = string
  description = "Project name — used in tags"
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

variable "buckets" {
  type = list(object({
    name         = string
    purpose      = string
    cold_after   = number
    expire_after = number
  }))
  description = "List of application buckets to create with lifecycle rules"
  default     = []

  validation {
    condition = alltrue([
      for b in var.buckets : b.cold_after > 0 && b.expire_after > b.cold_after
    ])
    error_message = "Each bucket must have cold_after > 0 and expire_after > cold_after."
  }
}
