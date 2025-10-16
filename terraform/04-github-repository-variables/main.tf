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
    key                         = "foundation/02-github-organization-variables/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}

data "terraform_remote_state" "_03" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://${var.region}.digitaloceanspaces.com"
    }
    bucket                      = "${var.bucket_name}"
    key                         = "foundation/03-github-repository/terraform.tfstate"
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
  owner = data.terraform_remote_state._02.outputs.github_organization
}


# Move local environment variables used for each step to the github repo variables so re-runs can be done through
# ci runners. Stored variables are either retrieved from state or from the local environment, while secrets will only
# be retrieved from the local environment, since these should be kept out of the state.

# 01-digitalocean-remote-state variables/secrets.
resource "github_actions_variable" "do_project_name" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "DO_organization_PROJECT_NAME"
  value       = data.terraform_remote_state._01.outputs.project_name
}
resource "github_actions_variable" "do_project_description" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "DO_organization_PROJECT_DESCRIPTION"
  value       = data.terraform_remote_state._01.outputs.project_description
}
resource "github_actions_variable" "do_project_purpose" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "DO_organization_PROJECT_PURPOSE"
  value       = data.terraform_remote_state._01.outputs.project_purpose
}
resource "github_actions_variable" "do_project_environment" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "DO_organization_PROJECT_ENVIRONMENT"
  value       = data.terraform_remote_state._01.outputs.project_environment
}

# resource "github_actions_variable" "do_region" {
#   repository  = data.terraform_remote_state._03.outputs.repository_name
#   variable_name = "DO_STATE_BUCKET_REGION"
#   value       = var.region
# }
# resource "github_actions_variable" "do_bucket_name" {
#   repository  = data.terraform_remote_state._03.outputs.repository_name
#   variable_name = "DO_STATE_BUCKET_NAME"
#   value       = data.terraform_remote_state._01.outputs.bucket_name
# }

resource "github_actions_secret" "do_token" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  secret_name = "STEP_01_DO_TOKEN"
  plaintext_value = var.do_token
}

# 02-github-organization variables/secrets.
# resource "github_actions_variable" "github_organization" {
#   repository  = data.terraform_remote_state._03.outputs.repository_name
#   variable_name = "ORGANIZATION_NAME"
#   value       = data.terraform_remote_state._02.outputs.github_organization
# }
#
resource "github_actions_secret" "github_org_vars_token" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  secret_name = "_GITHUB_ORG_VARS_TOKEN"
  plaintext_value = var.github_org_token
}

# 03-github-repository variables/secrets.
resource "github_actions_variable" "repository_name" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "REPOSITORY_NAME"
  value       = data.terraform_remote_state._03.outputs.repository_name
}
resource "github_actions_variable" "repository_description" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "REPOSITORY_DESCRIPTION"
  value       = data.terraform_remote_state._03.outputs.repository_description
}
resource "github_actions_variable" "repository_visibility" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "REPOSITORY_VISIBILITY"
  value       = data.terraform_remote_state._03.outputs.repository_visibility
}
resource "github_actions_variable" "template_owner" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "TEMPLATE_OWNER"
  value       = data.terraform_remote_state._03.outputs.template_owner
}
resource "github_actions_variable" "template_repository" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "TEMPLATE_REPOSITORY"
  value       = data.terraform_remote_state._03.outputs.template_repository
}
resource "github_actions_variable" "is_template" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "IS_TEMPLATE"
  value       = data.terraform_remote_state._03.outputs.is_template
}
#
resource "github_actions_secret" "github_repo_token" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  secret_name = "_GITHUB_CREATE_REPO_TOKEN"
  plaintext_value = var.github_repo_token
}

# 04-github-repository-variables variables/secrets.
resource "github_actions_variable" "github_repo_vars_token" {
  repository  = data.terraform_remote_state._03.outputs.repository_name
  variable_name = "_GITHUB_REPO_VARS_TOKEN"
  value       = var.github_repo_vars_token
}