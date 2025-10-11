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

# Read the 02-github-organization step inputs from its remote state
data "terraform_remote_state" "github_organisation" {
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

# Configure the GitHub provider with the same organization as the 02-github-organization step
provider "github" {
  token = var.github_repo_token
  owner = data.terraform_remote_state.github_organisation.outputs.github_organisation
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

# Add the organization name from the 02-github-organization step as a GitHub repository variable
resource "github_actions_variable" "github_organization" {
  repository  = github_repository.foundation.name
  variable_name = "ORGANIZATION_NAME"
  value       = data.terraform_remote_state.github_organisation.outputs.github_organisation
}


# Read the 01-digitalocean-remote-state step inputs from its remote state, and add them as GitHub repository variables
data "terraform_remote_state" "do_foundation" {
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
resource "github_actions_variable" "do_project_name" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_NAME"
  value       = data.terraform_remote_state.do_foundation.outputs.project_name
}
resource "github_actions_variable" "do_project_description" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_DESCRIPTION"
  value       = data.terraform_remote_state.do_foundation.outputs.project_description
}
resource "github_actions_variable" "do_project_purpose" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_PURPOSE"
  value       = data.terraform_remote_state.do_foundation.outputs.project_purpose
}
resource "github_actions_variable" "do_project_environment" {
  repository  = github_repository.foundation.name
  variable_name = "DO_ORGANISATION_PROJECT_ENVIRONMENT"
  value       = data.terraform_remote_state.do_foundation.outputs.project_environment
}

# Add this step's(03-github-foundation-repo) input variables as GitHub repository variables
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