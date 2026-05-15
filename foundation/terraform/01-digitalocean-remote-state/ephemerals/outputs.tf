# Output names match TF_VAR_* variable names in the parent step.
output "spaces_access_id" {
  value     = digitalocean_spaces_key.ephemeral.access_key
  sensitive = true
}

output "spaces_secret_key" {
  value     = digitalocean_spaces_key.ephemeral.secret_key
  sensitive = true
}
