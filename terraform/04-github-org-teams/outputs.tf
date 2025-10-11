output "devops_team_id" {
  description = "ID of the DevOps team"
  value       = github_team.devops.id
}

output "devops_team_name" {
  description = "Name of the DevOps team"
  value       = github_team.devops.name
}

output "development_team_id" {
  description = "ID of the Development team"
  value       = github_team.development.id
}

output "development_team_name" {
  description = "Name of the Development team"
  value       = github_team.development.name
}

output "qa_team_id" {
  description = "ID of the QA team"
  value       = github_team.qa.id
}

output "qa_team_name" {
  description = "Name of the QA team"
  value       = github_team.qa.name
}
