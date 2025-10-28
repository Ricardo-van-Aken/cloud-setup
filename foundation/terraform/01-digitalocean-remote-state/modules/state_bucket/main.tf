# Create bucket, and a bucket-specific key with read/write/delete access

terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Get the existing project
data "digitalocean_project" "existing" {
  id       = var.project_id
}

# Create DigitalOcean Space for remote state using the main provider
resource "digitalocean_spaces_bucket" "terraform_state" {
  name          = var.bucket_name
  region        = var.region
  force_destroy = true
}

# Create a bucket-specific Spaces access key for local usage (e.g., engineers running Terraform locally)
resource "digitalocean_spaces_key" "terraform_state_local" {
  name = "${var.bucket_name}.key-local"

  grant {
    bucket     = digitalocean_spaces_bucket.terraform_state.name
    permission = "readwrite"
  }
}

# Create a bucket-specific Spaces access key for CI/CD usage (to be stored in GitHub org secrets)
resource "digitalocean_spaces_key" "terraform_state_ci" {
  name = "${var.bucket_name}.key-ci"

  grant {
    bucket     = digitalocean_spaces_bucket.terraform_state.name
    permission = "readwrite"
  }
}

# Assign Space to project
resource "digitalocean_project_resources" "space" {
  project   = var.project_id
  resources = [digitalocean_spaces_bucket.terraform_state.urn]
}
