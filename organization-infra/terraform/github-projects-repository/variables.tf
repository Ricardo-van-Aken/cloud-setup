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
##     Repository Inputs     ##
###############################

variable "repository_name" {
  description = "Name of the repository"
  type        = string
  default     = "cloud-setup.projects"
}

variable "repository_description" {
  description = "Description of the repository"
  type        = string
  default     = "Template repository for cloud setup projects"
}

variable "template_owner" {
  description = "Owner of the template repository to use"
  type        = string
  default     = "Ricardo-van-Aken"
}

variable "template_repository" {
  description = "Name of the template repository to use"
  type        = string
  default     = "cloud-setup.projects"
}

