resource "digitalocean_database_cluster" "db-cluster" {
  name       = "${local.resource_name}-db"
  engine     = var._db_engine
  version    = var._db_engine_version
  size       = var.db_size_slug
  region     = var.region
  project_id = local.active_project_id
  node_count = var.db_node_count
  tags       = [digitalocean_tag.tag.id]
}

