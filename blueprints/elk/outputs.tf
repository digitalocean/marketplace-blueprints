output "app_url" {
  description = "URL of the Kibana web UI"
  value       = "http://${digitalocean_droplet.kibana.ipv4_address}:5601"
}

output "project_id" {
  description = "DigitalOcean project ID containing all stack resources"
  value       = digitalocean_project.elk.id
}

output "resource_name" {
  description = "Auto-generated name prefix used for the project, droplet hostnames, and stack tag (same as digitalocean_project.elk.name)"
  value       = local.resource_name
}

output "droplet_ids" {
  description = "Droplet IDs in fixed order: Elasticsearch, Kibana, Logstash"
  value = [
    digitalocean_droplet.elasticsearch.id,
    digitalocean_droplet.kibana.id,
    digitalocean_droplet.logstash.id,
  ]
}

output "droplet_ipv4_addresses" {
  description = "Public IPv4 addresses in the same order as droplet_ids: Elasticsearch, Kibana, Logstash"
  value = [
    digitalocean_droplet.elasticsearch.ipv4_address,
    digitalocean_droplet.kibana.ipv4_address,
    digitalocean_droplet.logstash.ipv4_address,
  ]
}

output "droplets" {
  description = "Each ELK component with droplet id and public IPv4"
  value = {
    elasticsearch = {
      id   = digitalocean_droplet.elasticsearch.id
      ipv4 = digitalocean_droplet.elasticsearch.ipv4_address
    }
    kibana = {
      id   = digitalocean_droplet.kibana.id
      ipv4 = digitalocean_droplet.kibana.ipv4_address
    }
    logstash = {
      id   = digitalocean_droplet.logstash.id
      ipv4 = digitalocean_droplet.logstash.ipv4_address
    }
  }
}
