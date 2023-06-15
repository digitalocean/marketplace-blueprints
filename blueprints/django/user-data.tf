data "template_file" "cloud-init-yaml" {
  template = file("./files/cloud-init.yaml")
  vars = {
    db_url = element(digitalocean_database_cluster.db-cluster, 0).uri
    db_protocol = "postgresql"
    db_host = element(digitalocean_database_cluster.db-cluster, 0).host
    db_port = element(digitalocean_database_cluster.db-cluster, 0).port
    db_username = element(digitalocean_database_cluster.db-cluster, 0).user
    db_password = element(digitalocean_database_cluster.db-cluster, 0).password
    db_name = element(digitalocean_database_cluster.db-cluster, 0).database
    project_url = var.project_url
  }
}
