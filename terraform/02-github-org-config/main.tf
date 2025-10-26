terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
  backend "s3" {}
}

provider "github" {
  token = var.github_org_config_token
  owner = var.github_organization
}

# Global organization teams (parent teams)
resource "github_team" "devops" {
  name        = "devops-team"
  description = "DevOps team responsible for infrastructure and deployments"
  privacy     = "closed"
}

resource "github_team" "development" {
  name        = "development-team"
  description = "Development team responsible for application development"
  privacy     = "closed"
}

resource "github_team" "qa" {
  name        = "qa-team"
  description = "Quality Assurance team responsible for testing"
  privacy     = "closed"
}

# DevOps sub-teams
resource "github_team" "devops_cheddar" {
  name           = "devops-team-cheddar"
  description    = "Cheddar DevOps sub-team"
  privacy        = "closed"
  parent_team_id = github_team.devops.id
}

resource "github_team" "devops_gouda" {
  name           = "devops-team-gouda"
  description    = "Gouda DevOps sub-team"
  privacy        = "closed"
  parent_team_id = github_team.devops.id
}

# Development sub-teams
resource "github_team" "development_brie" {
  name           = "development-team-brie"
  description    = "Brie Development sub-team"
  privacy        = "closed"
  parent_team_id = github_team.development.id
}

resource "github_team" "development_feta" {
  name           = "development-team-feta"
  description    = "Feta Development sub-team"
  privacy        = "closed"
  parent_team_id = github_team.development.id
}

# QA sub-teams
resource "github_team" "qa_parmesan" {
  name           = "qa-team-parmesan"
  description    = "Parmesan QA sub-team"
  privacy        = "closed"
  parent_team_id = github_team.qa.id
}

resource "github_team" "qa_swiss" {
  name           = "qa-team-swiss"
  description    = "Swiss QA sub-team"
  privacy        = "closed"
  parent_team_id = github_team.qa.id
}
