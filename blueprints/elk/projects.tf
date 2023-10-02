data "digitalocean_project" "selected_proj" {
  id = var.project_uuid
}

resource "digitalocean_project_resources" "project_resources" {
  project = data.digitalocean_project.selected_proj.id
  resources = [
    digitalocean_droplet.elasticsearch.urn,
    digitalocean_droplet.kibana.urn,
    digitalocean_droplet.logstash.urn,
  ]
}
