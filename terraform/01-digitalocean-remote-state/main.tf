terraform {
  required_version = "~> 1.11"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Base DO provider.
provider "digitalocean" {
  token = var.do_token
}

# Creates project.
module "project" {
  source = "./modules/project"

  do_token            = var.do_token

  project_name        = var.project_name
  project_description = var.project_description
  project_purpose     = var.project_purpose
  project_environment = var.project_environment

  providers = {
    digitalocean = digitalocean
  }
}

# General Spaces key.
module "general_spaces_key" {
  source = "./modules/general_spaces_key"

  providers = {
    digitalocean = digitalocean
  }
}

# Create an aliased provider for state bucket creation using general spaces key credentials.
provider "digitalocean" {
  alias = "DO_spaces_key"
  token = var.do_token

  spaces_access_id  = module.general_spaces_key.access_key
  spaces_secret_key = module.general_spaces_key.secret_key
}

# Bucket + bucket-specific key.
module "state_bucket" {
  source = "./modules/state_bucket"

  region                    = var.region
  project_id                = module.project.project_id
  bucket_name               = var.bucket_name

  providers = {
    digitalocean = digitalocean.DO_spaces_key
  }

  depends_on = [module.project, module.general_spaces_key]
}
