# GitHub Authentication
variable "github_org_token" {
  description = "GitHub Personal Access Token with organization admin permissions."
  type        = string
  sensitive   = true
}

variable "github_organisation" {
  description = "GitHub organization name."
  type        = string
}

# DigitalOcean spaces variables for connecting to the remote state bucket created in 01-digitalocean-remote-state
variable "region" {
  description = "DigitalOcean remote state bucket region."
  type        = string
  default     = "nyc1"
}
variable "bucket_name" {
  description = "DigitalOcean remote state bucket name."
  type        = string
}
