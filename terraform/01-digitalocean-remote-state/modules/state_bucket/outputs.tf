# Outputs for Stage 2 configuration

output "space_name" {
  description = "Name of the created Space"
  value       = digitalocean_spaces_bucket.terraform_state.name
}

output "space_region" {
  description = "Region of the created Space"
  value       = digitalocean_spaces_bucket.terraform_state.region
}

output "space_endpoint" {
  description = "Endpoint URL for the created Space"
  value       = digitalocean_spaces_bucket.terraform_state.endpoint
}

output "space_urn" {
  description = "URN of the created Space"
  value       = digitalocean_spaces_bucket.terraform_state.urn
}

output "project_id" {
  description = "ID of the project"
  value       = var.project_id
}

output "project_name" {
  description = "Name of the project"
  value       = data.digitalocean_project.existing.name
}

output "spaces_access_key_local" {
  description = "Bucket-specific Spaces access key for local usage"
  value       = digitalocean_spaces_key.terraform_state_local.access_key
  sensitive   = true
}

output "spaces_secret_key_local" {
  description = "Bucket-specific Spaces secret key for local usage"
  value       = digitalocean_spaces_key.terraform_state_local.secret_key
  sensitive   = true
}

output "spaces_access_key_ci" {
  description = "Bucket-specific Spaces access key for CI/CD usage"
  value       = digitalocean_spaces_key.terraform_state_ci.access_key
  sensitive   = true
}

output "spaces_secret_key_ci" {
  description = "Bucket-specific Spaces secret key for CI/CD usage"
  value       = digitalocean_spaces_key.terraform_state_ci.secret_key
  sensitive   = true
}
