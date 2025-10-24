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
resource "github_branch" "staging" {
  repository    = var.repository_name
  branch        = "staging"
  source_branch = "main"
}

resource "github_branch" "production" {
  repository    = var.repository_name
  branch        = "production"
  source_branch = "staging"
  
  depends_on = [github_branch.staging]
}

# Create repository environments with team reviewers
resource "github_repository_environment" "staging" {
  repository  = var.repository_name
  environment = "staging"
}

resource "github_repository_environment" "production" {
  repository  = var.repository_name
  environment = "production"

  reviewers {
    teams = [
      data.terraform_remote_state.github_org.outputs.devops_team_id
    ]
  }
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

# Branch protection for staging branch (basic protection)
resource "github_branch_protection" "staging" {
  repository_id = var.repository_name
  pattern       = "staging"

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
  
  depends_on = [github_branch.staging]
}

# Branch protection for production branch (most restrictive - DevOps only)
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
    contexts = ["test"]
  }

  enforce_admins = false
  
  depends_on = [github_branch.production]
}
