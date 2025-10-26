# Global organization teams
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

# Cheese team outputs
output "devops_cheddar_team_id" {
  description = "ID of the DevOps Cheddar team"
  value       = github_team.devops_cheddar.id
}

output "devops_gouda_team_id" {
  description = "ID of the DevOps Gouda team"
  value       = github_team.devops_gouda.id
}

output "development_brie_team_id" {
  description = "ID of the Development Brie team"
  value       = github_team.development_brie.id
}

output "development_feta_team_id" {
  description = "ID of the Development Feta team"
  value       = github_team.development_feta.id
}

output "qa_parmesan_team_id" {
  description = "ID of the QA Parmesan team"
  value       = github_team.qa_parmesan.id
}

output "qa_swiss_team_id" {
  description = "ID of the QA Swiss team"
  value       = github_team.qa_swiss.id
}
