locals {
  cloud_init_vars = {
    db_url      = digitalocean_database_cluster.db-cluster.uri
    db_protocol = var._db_protocol
    db_host     = digitalocean_database_cluster.db-cluster.host
    db_port     = digitalocean_database_cluster.db-cluster.port
    db_username = digitalocean_database_cluster.db-cluster.user
    db_password = digitalocean_database_cluster.db-cluster.password
    db_name     = digitalocean_database_cluster.db-cluster.database

    keystore_name     = digitalocean_database_cluster.kv-cluster.database
    keystore_protocol = var._keystore_protocol
    redis_conn_id     = var._keystore_connection_id
    redis_url         = digitalocean_database_cluster.kv-cluster.uri
    redis_host        = digitalocean_database_cluster.kv-cluster.host
    redis_port        = digitalocean_database_cluster.kv-cluster.port
    redis_username    = digitalocean_database_cluster.kv-cluster.user
    redis_password    = digitalocean_database_cluster.kv-cluster.password

    spaces_conn_type   = var._spaces_connection_type
    spaces_host        = "https://${var.region}.digitaloceanspaces.com"
    spaces_bucket_name = length(digitalocean_spaces_bucket.spaces_bucket) > 0 ? digitalocean_spaces_bucket.spaces_bucket[0].name : "${local.resource_name}-bucket"
    spaces_access_id   = var.spaces_access_id
    spaces_secret_key  = var.spaces_secret_key
    spaces_region      = var.region
    spaces_conn_id     = var._spaces_connection_id
  }
}
