terraform {
  required_version = "~> 1.12"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Base DO provider.
provider "digitalocean" {
  token = var.do_org_infra_token
}

# Creates project.
module "project" {
  source = "./modules/project"

  do_token            = var.do_org_infra_token

  project_name        = var.project_name
  project_description = var.project_description
  project_purpose     = var.project_purpose
  project_environment = var.project_environment

  providers = {
    digitalocean = digitalocean
  }
}

# Aliased provider authenticated with the ephemeral Spaces key (provided via TF_VAR_*).
provider "digitalocean" {
  alias = "DO_spaces_key"
  token = var.do_org_infra_token

  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}

# Bucket + bucket-specific key.
module "state_bucket" {
  source = "./modules/state_bucket"

  region     = var.region
  project_id = module.project.project_id
  bucket_name = var.bucket_name

  providers = {
    digitalocean = digitalocean.DO_spaces_key
  }

  depends_on = [module.project]
}
