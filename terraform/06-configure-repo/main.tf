terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Read outputs from the GitHub organization state
data "terraform_remote_state" "github_org" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/02-github-organization/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}

# Create production branch
resource "github_branch" "production" {
  repository = var.repository_name
  branch     = "production"
  source_branch = "main"
}

# Create production environment
resource "github_repository_environment" "production" {
  environment = "production"
  repository  = var.repository_name
}

# Create branch protection rule for production branch
resource "github_branch_protection" "production" {
  repository_id = var.repository_name
  
  pattern = "production"
  
  # Require pull request reviews
  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
  }
  
  # Require status checks
  required_status_checks {
    strict   = true
    contexts = ["ci"]
  }
  
  # Enforce admins
  enforce_admins = true
}
