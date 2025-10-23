terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.github_repo_config_token
  owner = var.github_organization
}

# Read outputs from the GitHub organization state
data "terraform_remote_state" "github_org" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/05-github-org-config/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}

# Optional: create branches that correspond to environments
resource "github_branch" "dev" {
  repository    = var.repository_name
  branch        = "dev"
  source_branch = "main"
}

resource "github_branch" "staging" {
  repository    = var.repository_name
  branch        = "staging"
  source_branch = "main"
}

resource "github_branch" "production" {
  repository    = var.repository_name
  branch        = "production"
  source_branch = "main"
}

# Create repository environments and require approvals for staging/production
locals {
  repository_environments = ["dev", "staging", "production"]
}

resource "github_repository_environment" "env" {
  for_each    = toset(local.repository_environments)
  repository  = var.repository_name
  environment = each.key

  dynamic "reviewers" {
    for_each = each.key == "production" ? [1] : []
    content {
      teams = [
        data.terraform_remote_state.github_org.outputs.devops_team_id
      ]
    }
  }

  dynamic "reviewers" {
    for_each = each.key == "staging" ? [1] : []
    content {
      teams = [
        data.terraform_remote_state.github_org.outputs.qa_team_id
      ]
    }
  }
}

# Optional: branch protection for production branch
resource "github_branch_protection" "production" {
  repository_id = var.repository_name
  pattern       = "production"

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }

  required_status_checks {
    strict   = true
    contexts = ["ci"]
  }

  enforce_admins = true
}
