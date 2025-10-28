terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_spaces_key" "general" {
  name = var.key_name

  grant {
    bucket     = ""
    permission = "fullaccess"
  }
}
