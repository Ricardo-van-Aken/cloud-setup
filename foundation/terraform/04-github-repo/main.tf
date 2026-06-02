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

# Read outputs from the GitHub organization state
data "terraform_remote_state" "github-org-config" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/github-org-config/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
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

# Add team access to the repository
resource "github_team_repository" "devops_gouda" {
  team_id    = data.terraform_remote_state.github-org-config.outputs.devops_gouda_team_id
  repository  = github_repository.foundation.name
  permission = "push"
}

# Create the production environment with team reviewers (used as the manual-approval gate by the foundation workflows)
resource "github_repository_environment" "production" {
  repository  = var.repository_name
  environment = "production"

  reviewers {
    teams = [
      data.terraform_remote_state.github-org-config.outputs.devops_gouda_team_id
    ]
  }

  depends_on = [
    github_team_repository.devops_gouda
  ]
}

# Branch protection for main branch (basic protection)
resource "github_branch_protection" "main" {
  repository_id = var.repository_name
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }

  required_status_checks {
    strict   = true
    contexts = ["test"]
  }

  enforce_admins = false
}