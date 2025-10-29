output "repository_name" {
  description = "The name of the created repository"
  value       = github_repository.projects_repository.name
}

output "repository_full_name" {
  description = "The full name (owner/name) of the repository"
  value       = github_repository.projects_repository.full_name
}

output "repository_url" {
  description = "The URL of the repository"
  value       = github_repository.projects_repository.html_url
}

