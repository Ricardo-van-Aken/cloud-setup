terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  backend "s3" {}
}

provider "github" {
  token = var.github_repo_token
  owner = var.github_organization
}

# Create the GitHub repository
resource "github_repository" "foundation" {
  name        = var.repository_name
  description = var.repository_description

  visibility = var.repository_visibility
  is_template = var.is_template

  template {
    owner      = var.template_owner
    repository = var.template_repository
  }
}