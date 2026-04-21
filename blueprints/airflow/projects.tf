resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  resource_name        = "${var.basename}-${random_string.suffix.result}"
  project_display_name = var.project_name != "" ? var.project_name : var.basename
}

# Create a new project if project_uuid is not provided
resource "digitalocean_project" "airflow" {
  count       = var.project_uuid == "" ? 1 : 0
  name        = local.project_display_name
  purpose     = "Data Workflow and Orchestration"
  environment = "Development"
}

# Use existing project if project_uuid is provided
data "digitalocean_project" "existing" {
  count = var.project_uuid != "" ? 1 : 0
  id    = var.project_uuid
}

locals {
  active_project_id = var.project_uuid == "" ? digitalocean_project.airflow[0].id : data.digitalocean_project.existing[0].id
}

resource "digitalocean_project_resources" "project_resources" {
  project = local.active_project_id

  resources = concat(
    [
      digitalocean_droplet.airflow.urn,
      digitalocean_database_cluster.db-cluster.urn,
      digitalocean_database_cluster.kv-cluster.urn,
    ],
    length(digitalocean_spaces_bucket.spaces_bucket) > 0 ? [digitalocean_spaces_bucket.spaces_bucket[0].urn] : []
  )
}
