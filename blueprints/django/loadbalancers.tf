resource "digitalocean_loadbalancer" "lb" {
  name   = var.lb_name
  region = var.region
  project_id = data.digitalocean_project.selected_proj.id

  # Add the droplets as backend servers for the load balancer
  droplet_ids = digitalocean_droplet.dropl[*].id

  # Add a health check to monitor the status of the backend servers
  healthcheck {
    port = 22
    protocol = "tcp"
  }

  # Add a forwarding rule to route incoming traffic to the backend servers
  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }
}
