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

variable "github_repo_vars_token" {
  description = "GitHub Personal Access Token for creating the github repository"
  type        = string
  sensitive   = true
}
variable "github_organization" {
  description = "Name of the GitHub organization"
  type        = string
}

###############################
##   Local Secrets           ##
###############################

variable "do_token" {
  description = "DigitalOcean token from step 01-digitalocean-remote-state"
  type        = string
  sensitive   = true
}
variable "github_org_token" {
  description = "GitHub Personal Access Token from step 02-github-organization"
  type        = string
  sensitive   = true
}
variable "github_repo_token" {
  description = "GitHub Personal Access Token from step 03-github-repository"
  type        = string
  sensitive   = true
}
