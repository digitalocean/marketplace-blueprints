output "droplet_id" {
  description = "ID of created droplet"
  value       = digitalocean_droplet.airflow.id
}

output "redis_id" {
  description = "ID of created keystore (Valkey)"
  value       = digitalocean_database_cluster.kv-cluster.id
}

output "bucket_id" {
  description = "ID of created spaces bucket (if Spaces credentials were provided)"
  value       = length(digitalocean_spaces_bucket.spaces_bucket) > 0 ? digitalocean_spaces_bucket.spaces_bucket[0].id : "Not created - provide spaces_access_id and spaces_secret_key to enable"
}

output "spaces_bucket_endpoint" {
  description = "The API endpoint for the Spaces bucket (if created)"
  value       = length(digitalocean_spaces_bucket.spaces_bucket) > 0 ? digitalocean_spaces_bucket.spaces_bucket[0].endpoint : "Not created - provide spaces_access_id and spaces_secret_key to enable"
}

# Resource ID outputs for stack_resources tracking.
output "database_ids" {
  value       = [digitalocean_database_cluster.db-cluster.id, digitalocean_database_cluster.kv-cluster.id]
  description = "Database cluster resource IDs (Postgres + Valkey)."
}
