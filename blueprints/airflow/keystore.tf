resource "digitalocean_database_cluster" "kv-cluster" {
  name       = var.keystore_name
  engine     = var._keystore_engine
  version    = var._keystore_engine_version
  size       = var.keystore_size_slug
  region     = var.region
  project_id = data.digitalocean_project.selected_proj.id
  node_count = var.keystore_node_count
  tags = [for k, v in digitalocean_tag.tags : v.id]
}