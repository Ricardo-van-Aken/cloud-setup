###############################
##   Remote State Bucket     ##
###############################

variable "region" {
  description = "DigitalOcean remote state bucket region."
  type        = string
  default     = "nyc1"
}
variable "bucket_name" {
  description = "DigitalOcean remote state bucket name."
  type        = string
}

################################
##   Provider Authorization   ##
################################

variable "github_repo_token" {
  description = "GitHub Personal Access Token for creating the github repository"
  type        = string
  sensitive   = true
}
variable "github_organization" {
  description = "Name of the GitHub organization"
  type        = string
}

###############################
##   Repository Settings    ##
###############################

variable "repository_name" {
  description = "Name of the repository"
  type        = string
  default     = "cloud-setup.foundation"
}
variable "repository_description" {
  description = "Description of the repository"
  type        = string
  default     = "This repository provisions the organization-wide platform foundation used by all projects and CI/CD pipelines. It bootstraps remote Terraform state, configures the GitHub organization, and deploys shared cloud resources such as a Vault."
}
variable "repository_visibility" {
  description = "Repository visibility (public, private, internal)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["public", "private", "internal"], var.repository_visibility)
    error_message = "Repository visibility must be one of: public, private, internal."
  }
}
variable "template_owner" {
  description = "Owner of the template repository"
  type        = string
  default     = "Ricardo-van-Aken"
}
variable "template_repository" {
  description = "Name of the template repository"
  type        = string
  default     = "cloud-setup.foundation"
}
variable "is_template" {
  description = "Whether to make this repository a template repository"
  type        = bool
  default     = false
}
