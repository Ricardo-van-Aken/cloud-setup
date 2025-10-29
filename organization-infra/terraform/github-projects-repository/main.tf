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

# Read outputs from the GitHub organization state (02-github-org-config)
data "terraform_remote_state" "github_org_config" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = var.bucket_name
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

# Create the GitHub repository from template
resource "github_repository" "projects_repository" {
  name        = var.repository_name
  description = var.repository_description

  visibility  = "public"
  is_template = true

  template {
    owner      = var.template_owner
    repository = var.template_repository
  }
}

# Overwrite some private variables from the organization secrets by placing them in the repository secrets, in case
# the github plan does not support the use of organisation secrets in private repositories. You can remove this part
# if you are using a github plan that does support this feature.
resource "github_actions_secret" "spaces_secret_key_ci" {
  repository    = github_repository.projects_repository.name
  secret_name   = "DO_STATE_BUCKET_SECRET_KEY"
  plaintext_value = data.terraform_remote_state.github_org_config.outputs.bucket_spaces_secret_key_ci
}

