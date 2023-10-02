output "droplet_ids" {
  description = "IDs of created droplets"
  value       = [ digitalocean_droplet.elasticsearch.id,
                  digitalocean_droplet.kibana.id,
                  digitalocean_droplet.logstash.id ]
}
