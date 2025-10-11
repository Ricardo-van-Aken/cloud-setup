output "project_id" {
  value       = module.project.project_id
  description = "Project ID created, used by other stages for organisational resources."
}

output "space_name" {
  value       = try(module.state_bucket.space_name, null)
  description = "Spaces bucket name, used for remote state storage."
}

output "bucket_spaces_access_key_local" {
  value       = module.state_bucket.spaces_access_key_local
  sensitive   = true
  description = "Bucket-specific Spaces access key for remote state backend (local usage)."
}

output "bucket_spaces_secret_key_local" {
  value       = module.state_bucket.spaces_secret_key_local
  sensitive   = true
  description = "Bucket-specific Spaces secret key for remote state backend (local usage)."
}

output "bucket_spaces_access_key_ci" {
  value       = module.state_bucket.spaces_access_key_ci
  sensitive   = true
  description = "Bucket-specific Spaces access key for remote state backend (CI/CD usage)."
}

output "bucket_spaces_secret_key_ci" {
  value       = module.state_bucket.spaces_secret_key_ci
  sensitive   = true
  description = "Bucket-specific Spaces secret key for remote state backend (CI/CD usage)."
}

# Expose input variables for use by other stacks
output "project_name" {
  value       = var.project_name
  description = "Project name used in this stack."
}

output "project_description" {
  value       = var.project_description
  description = "Project description used in this stack."
}

output "project_purpose" {
  value       = var.project_purpose
  description = "Project purpose used in this stack."
}

output "project_environment" {
  value       = var.project_environment
  description = "Project environment used in this stack."
}

output "region" {
  value       = var.region
  description = "DigitalOcean region used in this stack."
}

output "bucket_name" {
  value       = var.bucket_name
  description = "DigitalOcean Spaces bucket name used for remote state storage."
}
