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

# Create DevOps team
resource "github_team" "devops" {
  name        = "devops-team"
  description = "DevOps team responsible for infrastructure and deployments"
  privacy     = "closed"
}

# Create Development team
resource "github_team" "development" {
  name        = "development-team"
  description = "Development team responsible for application development"
  privacy     = "closed"
}

# Create QA team
resource "github_team" "qa" {
  name        = "qa-team"
  description = "Quality Assurance team responsible for testing"
  privacy     = "closed"
}
