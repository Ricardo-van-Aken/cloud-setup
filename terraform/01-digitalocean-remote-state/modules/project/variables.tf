variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the DigitalOcean project to use (defaults to 'Default')"
  type        = string
  default     = "Default"
}

variable "project_description" {
  description = "Description of the DigitalOcean project (only used when creating custom projects)"
  type        = string
  default     = "Project for organization infrastructure"
}

variable "project_purpose" {
  description = "Purpose of the DigitalOcean project (only used when creating custom projects)"
  type        = string
  default     = "Hold Organization Resources such as remote terraform state"
}

variable "project_environment" {
  description = "Environment of the DigitalOcean project (only used when creating custom projects)"
  type        = string
  default     = "development"
}
