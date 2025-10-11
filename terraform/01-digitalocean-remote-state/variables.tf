variable "do_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Name for the DigitalOcean Spaces bucket used for remote state storage. Must be unique within its own region."
  type        = string
}
variable "region" {
  description = "DigitalOcean region."
  type        = string
  default     = "nyc1"
}

variable "project_name" {
  description = "Project name given to the project created in this stack."
  type        = string
  default     = "Organisation Infrastructure"
}

variable "project_description" {
  description = "Project description given to the project created in this stack."
  type        = string
  default     = "Shared infrastructure for organisation-wide resources"
}

variable "project_purpose" {
  description = "Project purpose given to the project created in this stack."
  type        = string
  default     = "Hold Organisation Resources such as remote terraform state, which are shared throughout the organisation."
}

variable "project_environment" {
  description = "Project environment given to the project created in this stack."
  type        = string
  default     = "development"
}