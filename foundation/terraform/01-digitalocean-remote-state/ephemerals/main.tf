terraform {
  required_version = "~> 1.12"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  # No backend — local state only. Destroyed after every apply.
}

provider "digitalocean" {
  token = var.do_org_infra_token
}

resource "digitalocean_spaces_key" "ephemeral" {
  name = "ephemeral-bootstrap-key"

  grant {
    bucket     = ""
    permission = "fullaccess"
  }
}
