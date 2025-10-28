###############################
##   Remote State Bucket     ##
###############################

variable "bucket_name" {
  description = "Name for the DigitalOcean Spaces bucket used for remote state storage. Must be unique within its own region."
  type        = string
}
variable "region" {
  description = "DigitalOcean region."
  type        = string
  default     = "nyc1"
}

################################
##   Provider Authorization   ##
################################

variable "do_org_infra_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "spaces_access_id" {
  description = "Optional: DigitalOcean Spaces access ID for the aliased provider. If not provided, will use module output (creates circular dependency on first run)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "Optional: DigitalOcean Spaces secret key for the aliased provider. If not provided, will use module output (creates circular dependency on first run)."
  type        = string
  default     = ""
  sensitive   = true
}

###############################
##   Project Configuration   ##
###############################

variable "project_name" {
  description = "Project name given to the project created in this stack."
  type        = string
  default     = "organization Infrastructure"
}
variable "project_description" {
  description = "Project description given to the project created in this stack."
  type        = string
  default     = "Shared infrastructure for organization-wide resources"
}

variable "project_purpose" {
  description = "Project purpose given to the project created in this stack."
  type        = string
  default     = "Hold organization Resources such as remote terraform state, which are shared throughout the organization."
}

variable "project_environment" {
  description = "Project environment given to the project created in this stack."
  type        = string
  default     = "development"
}