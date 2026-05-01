variable "project_name" {
  type        = string
  description = "Project name — used as prefix for all resource names"
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

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private network subnet (e.g. 10.0.0.0/20)"
  default     = "10.0.0.0/20"
  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "private_subnet_cidr must be a valid CIDR block."
  }
}

variable "gateway_type" {
  type        = string
  description = "Public gateway type — VPC-GW-S (1 Gbps) or VPC-GW-M (10 Gbps)"
  default     = "VPC-GW-S"
  validation {
    condition     = contains(["VPC-GW-S", "VPC-GW-M"], var.gateway_type)
    error_message = "gateway_type must be VPC-GW-S or VPC-GW-M."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged into all resources"
  default     = {}
}
