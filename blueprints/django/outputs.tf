output "load_balancer_ids" {
  description = "IDs of created load balancers"
  value       = digitalocean_loadbalancer.lb.id
}

output "droplet_ids" {
  description = "IDs of created droplets"
  value       = digitalocean_droplet.dropl[*].id
}

output "database_ids" {
  description = "ID of created database cluster"
  value = digitalocean_database_cluster.db-cluster.id
}
