output "droplet_id" {
  description = "ID of created droplet"
  value       = digitalocean_droplet.airflow.id
}

output "database_id" {
  description = "ID of created database cluster"
  value = digitalocean_database_cluster.db-cluster.id
}

output "redis_id" {
  description = "ID of created keystore"
  value       = digitalocean_database_cluster.kv-cluster.id
}

output "bucket_id" {
  description = "ID of created spaces bucket"
  value = digitalocean_spaces_bucket.spaces_bucket.id
}

output "spaces_bucket_endpoint" {
  description = "The API endpoint for the Spaces bucket"
  value       = digitalocean_spaces_bucket.spaces_bucket.endpoint
}

output "spaces_access_id" {
  description = "The newly generated Spaces Access Key ID"
  value       = digitalocean_spaces_key.airflow_key.access_key
  sensitive   = true
}

output "spaces_secret_key" {
  description = "The newly generated Spaces Secret Key"
  value       = digitalocean_spaces_key.airflow_key.secret_key
  sensitive   = true
}
