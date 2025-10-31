terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.45.0"
    }
  }
  backend "s3" {}
}

provider "github" {
  token = var.github_repo_token
  owner = var.github_organization
}

# Provider alias used for managing repository variables and secrets
provider "github" {
  alias = "repo_vars"
  token = var.github_repo_vars_token
  owner = var.github_organization
}

data "terraform_remote_state" "do-remote-state" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/digitalocean-remote-state/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}

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

# Create the GitHub repository from template
resource "github_repository" "projects_repository" {
  name        = var.repository_name
  description = var.repository_description

  visibility = var.repository_visibility
  is_template = var.is_template

  template {
    owner      = var.template_owner
    repository = var.template_repository
  }
}

# Add a production environment with DevOps team as reviewers
resource "github_repository_environment" "production" {
  repository  = github_repository.projects_repository.name
  environment = "production"

  reviewers {
    teams = [data.terraform_remote_state.github-org-config.outputs.devops_team_id]
  }

  depends_on = [github_repository.projects_repository]
}

# Grant team access to the repository
resource "github_team_repository" "devops" {
  team_id    = data.terraform_remote_state.github-org-config.outputs.devops_team_id
  repository = github_repository.projects_repository.name
  permission = "push"
}

resource "github_team_repository" "development" {
  team_id    = data.terraform_remote_state.github-org-config.outputs.development_team_id
  repository = github_repository.projects_repository.name
  permission = "push"
}

resource "github_team_repository" "qa" {
  team_id    = data.terraform_remote_state.github-org-config.outputs.qa_team_id
  repository = github_repository.projects_repository.name
  permission = "pull"
}

# Overwrite some private variables from the organization secrets by placing them in the repository secrets, in case
# the github plan does not support the use of organisation secrets in private repositories. You can remove this part
# if you are using a github plan that does support this feature.
resource "github_actions_secret" "spaces_secret_key_ci" {
  provider      = github.repo_vars
  repository    = github_repository.projects_repository.name
  secret_name   = "DO_STATE_BUCKET_SECRET_KEY"
  plaintext_value = data.terraform_remote_state.do-remote-state.outputs.bucket_spaces_secret_key_ci
  
  depends_on = [github_repository.projects_repository]
}

# Expose tokens needed by project workflows as repository secrets
resource "github_actions_secret" "github_repo_token" {
  provider      = github.repo_vars
  repository    = github_repository.projects_repository.name
  secret_name   = "_GITHUB_REPO_TOKEN"
  plaintext_value = var.github_repo_token

  depends_on = [github_repository.projects_repository]
}

resource "github_actions_secret" "github_repo_vars_token" {
  provider      = github.repo_vars
  repository    = github_repository.projects_repository.name
  secret_name   = "_GITHUB_REPO_VARS_TOKEN"
  plaintext_value = var.github_repo_vars_token

  depends_on = [github_repository.projects_repository]
}