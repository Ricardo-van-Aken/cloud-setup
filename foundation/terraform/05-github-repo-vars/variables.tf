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

variable "github_organization" {
  description = "Name of the GitHub organization"
  type        = string
}

###############################
##   Local Secrets           ##
###############################

variable "do_org_infra_token" {
  description = "DigitalOcean token from step 01-digitalocean-remote-state"
  type        = string
  sensitive   = true
}
variable "github_org_token" {
  description = "GitHub Personal Access Token with organization-level permissions (members, secrets, variables)"
  type        = string
  sensitive   = true
}
variable "github_repo_token" {
  description = "GitHub Personal Access Token with repository-level permissions (administration, contents, actions, secrets, variables)"
  type        = string
  sensitive   = true
}
