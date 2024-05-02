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
