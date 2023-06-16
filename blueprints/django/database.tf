resource "digitalocean_database_cluster" "db-cluster" {
  count      = 1
  name       = var.db_cluster_name
  engine     = var.db_engine
  version    = var.db_engine_version
  size       = var.db_size_slug
  region     = var.region
  project_id = data.digitalocean_project.selected_proj.id
  node_count = 1
  tags = [for k, v in digitalocean_tag.tags : v.id]
}

resource "random_password" "password" {
  length = 24
  special = false
}
