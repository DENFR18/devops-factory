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

variable "project_id" {
  type        = string
  description = "Scaleway project ID — scope all IAM rules to this project"
}

variable "prevent_destroy" {
  type        = bool
  description = "Protect the IAM application from accidental deletion"
  default     = false
}
