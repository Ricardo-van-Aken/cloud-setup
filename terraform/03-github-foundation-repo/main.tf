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

data "terraform_remote_state" "_01" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/01-digitalocean-remote-state/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}

data "terraform_remote_state" "_02" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/02-github-organisation/terraform.tfstate"
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
  token = var.github_repo_token
  owner = data.terraform_remote_state._02.outputs.github_organisation
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


# Move local environment variables used for each step to the github repo variables so re-runs can be done through
# ci runners. Stored variables are either retrieved from state or from the local environment, while secrets will only
# be retrieved from the local environment, since these should be kept out of the state.

# 01-digitalocean-remote-state variables/secrets.
resource "github_actions_variable" "do_region" {
  repository  = github_repository.foundation.name
  variable_name = "DO_REGION"
  value       = var.region
}
resource "github_actions_variable" "do_project_name" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_NAME"
  value       = data.terraform_remote_state._01.outputs.project_name
}
resource "github_actions_variable" "do_project_description" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_DESCRIPTION"
  value       = data.terraform_remote_state._01.outputs.project_description
}
resource "github_actions_variable" "do_project_purpose" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_PURPOSE"
  value       = data.terraform_remote_state._01.outputs.project_purpose
}
resource "github_actions_variable" "do_project_environment" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_ENVIRONMENT"
  value       = data.terraform_remote_state._01.outputs.project_environment
}

# 02-github-organization variables/secrets.
resource "github_actions_variable" "github_organization" {
  repository  = github_repository.foundation.name
  variable_name = "ORGANIZATION_NAME"
  value       = data.terraform_remote_state._02.outputs.github_organisation
}

resource "github_actions_secret" "github_organisation_token" {
  repository  = github_repository.foundation.name
  secret_name = "STEP_02_GITHUB_TOKEN"
  plaintext_value = var.github_org_token
}

# 03-github-foundation-repo.
resource "github_actions_variable" "repository_name" {
  repository  = github_repository.foundation.name
  variable_name = "REPOSITORY_NAME"
  value       = var.repository_name
}
resource "github_actions_variable" "repository_description" {
  repository  = github_repository.foundation.name
  variable_name = "REPOSITORY_DESCRIPTION"
  value       = var.repository_description
}
resource "github_actions_variable" "repository_visibility" {
  repository  = github_repository.foundation.name
  variable_name = "REPOSITORY_VISIBILITY"
  value       = var.repository_visibility
}
resource "github_actions_variable" "template_owner" {
  repository  = github_repository.foundation.name
  variable_name = "TEMPLATE_OWNER"
  value       = var.template_owner
}
resource "github_actions_variable" "template_repository" {
  repository  = github_repository.foundation.name
  variable_name = "TEMPLATE_REPOSITORY"
  value       = var.template_repository
}
resource "github_actions_variable" "is_template" {
  repository  = github_repository.foundation.name
  variable_name = "IS_TEMPLATE"
  value       = var.is_template
}

resource "github_actions_secret" "github_repo_token" {
  repository  = github_repository.foundation.name
  secret_name = "STEP_03_GITHUB_TOKEN"
  plaintext_value = var.github_repo_token
}