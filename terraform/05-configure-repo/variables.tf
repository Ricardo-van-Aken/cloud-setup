variable "repository_name" {
  description = "Name of the GitHub repository"
  type        = string
}


variable "github_token" {
  description = "GitHub token for authentication"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for remote state"
  type        = string
}

variable "bucket_name" {
  description = "DigitalOcean Spaces bucket name for remote state"
  type        = string
}
