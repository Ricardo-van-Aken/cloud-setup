output "repository_name" {
  description = "Name of the created repository"
  value       = github_repository.foundation.name
}

output "repository_full_name" {
  description = "Full name of the repository (owner/repo)"
  value       = github_repository.foundation.full_name
}

output "repository_url" {
  description = "URL of the repository"
  value       = github_repository.foundation.html_url
}

output "repository_clone_url_https" {
  description = "HTTPS clone URL of the repository"
  value       = github_repository.foundation.http_clone_url
}

output "repository_clone_url_ssh" {
  description = "SSH clone URL of the repository"
  value       = github_repository.foundation.ssh_clone_url
}

# Expose input variables for later use by other stacks through remote state
output "repository_description" {
  description = "Repository description provided as input"
  value       = var.repository_description
}

output "repository_visibility" {
  description = "Repository visibility provided as input"
  value       = var.repository_visibility
}

output "template_owner" {
  description = "Template repository owner provided as input"
  value       = var.template_owner
}

output "template_repository" {
  description = "Template repository name provided as input"
  value       = var.template_repository
}

output "is_template" {
  description = "Whether the repository is a template (input)"
  value       = var.is_template
}

# Branch and environment outputs
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

output "environment_reviewers" {
  description = "Reviewers for the production environment"
  value       = github_repository_environment.production.reviewers
}