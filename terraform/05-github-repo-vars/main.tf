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

data "terraform_remote_state" "github-repo" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/github-repo/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}

provider "github" {
  token = var.github_repo_vars_token
  owner = var.github_organization
}


# Move local environment variables used for each step to the github repo variables so re-runs can be done through
# ci runners. Stored variables are either retrieved from state or from the local environment, while secrets will only
# be retrieved from the local environment, since these should be kept out of the state.

# 01-digitalocean-remote-state variables/secrets.
resource "github_actions_variable" "do_project_name" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "DO_organization_PROJECT_NAME"
  value       = data.terraform_remote_state.do-remote-state.outputs.project_name
}
resource "github_actions_variable" "do_project_description" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "DO_organization_PROJECT_DESCRIPTION"
  value       = data.terraform_remote_state.do-remote-state.outputs.project_description
}
resource "github_actions_variable" "do_project_purpose" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "DO_organization_PROJECT_PURPOSE"
  value       = data.terraform_remote_state.do-remote-state.outputs.project_purpose
}
resource "github_actions_variable" "do_project_environment" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "DO_organization_PROJECT_ENVIRONMENT"
  value       = data.terraform_remote_state.do-remote-state.outputs.project_environment
}


resource "github_actions_secret" "do_token" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  secret_name = "DO_ORG_INFRA_TOKEN"
  plaintext_value = var.do_org_infra_token
}

# Overwrite some private variables from the 02-github-organization-variables step, in case your github plan does not
# support this feature. You can remove this part if you are using a github plan that supports private environment
# variables in the organization.
resource "github_actions_secret" "spaces_secret_key_ci" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  secret_name = "DO_SPACES_SECRET_KEY_CI"
  plaintext_value = data.terraform_remote_state.do-remote-state.outputs.bucket_spaces_secret_key_ci
}

# 02-github-org-config variables/secrets.
resource "github_actions_secret" "github_org_config_token" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  secret_name = "_GITHUB_ORG_CONFIG_TOKEN"
  plaintext_value = var.github_org_config_token
}

# 03-github-org-vars variables/secrets.
resource "github_actions_secret" "github_org_vars_token" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  secret_name = "_GITHUB_ORG_VARS_TOKEN"
  plaintext_value = var.github_org_vars_token
}

# 04-github-repo variables/secrets.
resource "github_actions_variable" "repository_name" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "REPOSITORY_NAME"
  value       = data.terraform_remote_state.github-repo.outputs.repository_name
}
resource "github_actions_variable" "repository_description" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "REPOSITORY_DESCRIPTION"
  value       = data.terraform_remote_state.github-repo.outputs.repository_description
}
resource "github_actions_variable" "repository_visibility" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "REPOSITORY_VISIBILITY"
  value       = data.terraform_remote_state.github-repo.outputs.repository_visibility
}
resource "github_actions_variable" "template_owner" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "TEMPLATE_OWNER"
  value       = data.terraform_remote_state.github-repo.outputs.template_owner
}
resource "github_actions_variable" "template_repository" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "TEMPLATE_REPOSITORY"
  value       = data.terraform_remote_state.github-repo.outputs.template_repository
}
resource "github_actions_variable" "is_template" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "IS_TEMPLATE"
  value       = data.terraform_remote_state.github-repo.outputs.is_template
}
#
resource "github_actions_secret" "github_repo_token" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  secret_name = "_GITHUB_REPO_TOKEN"
  plaintext_value = var.github_repo_token
}

# 04-github-repository-variables variables/secrets.
resource "github_actions_variable" "github_repo_vars_token" {
  repository  = data.terraform_remote_state.github-repo.outputs.repository_name
  variable_name = "_GITHUB_REPO_VARS_TOKEN"
  value       = var.github_repo_vars_token
}