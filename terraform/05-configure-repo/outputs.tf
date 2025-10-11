output "production_branch_name" {
  description = "Name of the production branch"
  value       = github_branch.production.branch
}

output "production_environment_name" {
  description = "Name of the production environment"
  value       = github_repository_environment.production.environment
}

output "branch_protection_id" {
  description = "ID of the branch protection rule"
  value       = github_branch_protection.production.id
}

output "environment_protection_rules" {
  description = "Protection rules for the production environment"
  value       = github_repository_environment.production.protection_rules
}
