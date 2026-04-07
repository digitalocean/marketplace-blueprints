resource "digitalocean_database_cluster" "kv-cluster" {
  name       = "${local.resource_name}-keystore"
  engine     = var._keystore_engine
  version    = var._keystore_engine_version
  size       = var.keystore_size_slug
  region     = var.region
  project_id = local.active_project_id
  node_count = var.keystore_node_count
  tags       = [digitalocean_tag.tag.id]
}

