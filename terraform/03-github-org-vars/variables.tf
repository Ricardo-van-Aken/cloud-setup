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

variable "github_org_token" {
  description = "GitHub Personal Access Token with organization admin permissions."
  type        = string
  sensitive   = true
}
variable "github_organization" {
  description = "GitHub organization name."
  type        = string
}
