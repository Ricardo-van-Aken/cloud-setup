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
