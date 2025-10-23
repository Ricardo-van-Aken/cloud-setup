variable "region" {
  description = "DigitalOcean region for remote state"
  type        = string
}

variable "bucket_name" {
  description = "DigitalOcean Spaces bucket name for remote state"
  type        = string
}

variable "github_org_config_token" {
  description = "GitHub token for authentication"
  type        = string
  sensitive   = true
}

variable "github_organization" {
  description = "Name of the GitHub organization"
  type        = string
}