data "digitalocean_project" "selected_proj" {
  id = var.project_uuid
}

resource "digitalocean_project_resources" "project_resources" {
  project = data.digitalocean_project.selected_proj.id
  resources = concat(
    digitalocean_droplet.dropl[*].urn,
    digitalocean_database_cluster.db-cluster.urn,
    digitalocean_loadbalancer.lb.urn
  )
}
