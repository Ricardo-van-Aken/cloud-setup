# Create project and general Spaces key

terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Get or create project
data "digitalocean_project" "default" {
  count    = var.project_name == "Default" ? 1 : 0
  name     = "Default"
}

resource "digitalocean_project" "custom" {
  count       = var.project_name == "Default" ? 0 : 1
  name        = var.project_name
  description = var.project_description
  purpose     = var.project_purpose
  environment = var.project_environment
}

locals {
  project_id = var.project_name == "Default" ? data.digitalocean_project.default[0].id : digitalocean_project.custom[0].id
}

