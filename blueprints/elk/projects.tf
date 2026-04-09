resource "digitalocean_project" "elk" {
  name        = local.resource_name
  description = "Terraform-managed ELK stack (Elasticsearch, Kibana, Logstash): ${local.resource_name}"
  purpose     = "Operational / Developer tooling"
  environment = "Development"
}

resource "digitalocean_project_resources" "project_resources" {
  project = digitalocean_project.elk.id
  resources = [
    digitalocean_droplet.elasticsearch.urn,
    digitalocean_droplet.kibana.urn,
    digitalocean_droplet.logstash.urn,
  ]
}
