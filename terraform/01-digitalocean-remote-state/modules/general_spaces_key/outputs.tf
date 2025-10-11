output "access_key" {
  value       = digitalocean_spaces_key.general.access_key
  sensitive   = true
  description = "Spaces general access, access key"
}

output "secret_key" {
  value       = digitalocean_spaces_key.general.secret_key
  sensitive   = true
  description = "Spaces general access, secret key"
}
