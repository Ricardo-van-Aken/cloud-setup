# Organization-level resources (shared infrastructure)
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

# GitHub provider configuration
provider "github" {
  token = var.github_org_vars_token
  owner = var.github_organization
}

# Read outputs from the DigitalOcean foundation state stored in Spaces
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

# Organization secrets
# Expose DigitalOcean Spaces CI credentials as GitHub Organization secrets
resource "github_actions_organization_variable" "spaces_access_key_ci" {
  variable_name     = "DO_SPACES_ACCESS_KEY_CI"
  visibility      = "all"
  value = data.terraform_remote_state.do-remote-state.outputs.bucket_spaces_access_key_ci
}

resource "github_actions_organization_secret" "spaces_secret_key_ci" {
  secret_name     = "DO_SPACES_SECRET_KEY_CI"
  visibility      = "private"
  plaintext_value = data.terraform_remote_state.do-remote-state.outputs.bucket_spaces_secret_key_ci
}

# Organization variables
resource "github_actions_organization_variable" "organization_name" {
  variable_name = "organization_NAME"
  visibility      = "all"
  value           = var.github_organization
}
# Expose DigitalOcean Spaces bucket name and region as a GitHub organization variable
resource "github_actions_organization_variable" "do_bucket_name" {
  variable_name = "DO_STATE_BUCKET_NAME"
  visibility      = "all"
  value       = data.terraform_remote_state.do-remote-state.outputs.bucket_name
}
resource "github_actions_organization_variable" "do_bucket_region" {
  variable_name = "DO_STATE_BUCKET_REGION"
  visibility      = "all"
  value       = data.terraform_remote_state.do-remote-state.outputs.region
}
