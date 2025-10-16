terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Create DevOps team
resource "github_team" "devops" {
  name        = "devops-team"
  description = "DevOps team responsible for infrastructure and deployments"
  privacy     = "closed"
}

# Create Development team
resource "github_team" "development" {
  name        = "development-team"
  description = "Development team responsible for application development"
  privacy     = "closed"
}

# Create QA team
resource "github_team" "qa" {
  name        = "qa-team"
  description = "Quality Assurance team responsible for testing"
  privacy     = "closed"
}
