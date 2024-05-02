resource "digitalocean_database_cluster" "db-cluster" {
  name       = var.db_cluster_name
  engine     = var._db_engine
  version    = var._db_engine_version
  size       = var.db_size_slug
  region     = var.region
  project_id = data.digitalocean_project.selected_proj.id
  node_count = var.db_node_count
  tags = [for k, v in digitalocean_tag.tags : v.id]
}