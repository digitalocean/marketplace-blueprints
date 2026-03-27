resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  resource_name = "${var.base_name}-${random_string.suffix.result}"
}

data "digitalocean_project" "selected_proj" {
  count = var.project_uuid == "" ? 0 : 1
  id    = var.project_uuid
}

resource "digitalocean_project" "airflow" {
  count       = var.project_uuid == "" ? 1 : 0
  name        = var.base_name
  purpose     = "Data Workflow and Orchestration"
  environment = "Testing"
}

locals {
  active_project_id = var.project_uuid == "" ? digitalocean_project.airflow[0].id : data.digitalocean_project.selected_proj[0].id
}

resource "digitalocean_project_resources" "project_resources" {
  project = local.active_project_id
  
  resources = [
    digitalocean_droplet.airflow.urn,
    digitalocean_database_cluster.db-cluster.urn,
    digitalocean_database_cluster.keystore.urn
  ]
}