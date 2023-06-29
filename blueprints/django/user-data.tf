data "template_file" "cloud-init-yaml" {
  template = file("./files/cloud-init.yaml")
  vars = {
    db_url = digitalocean_database_cluster.db-cluster.uri
    db_protocol = "postgresql"
    db_host = digitalocean_database_cluster.db-cluster.host
    db_port = digitalocean_database_cluster.db-cluster.port
    db_username = digitalocean_database_cluster.db-cluster.user
    db_password = digitalocean_database_cluster.db-cluster.password
    db_name = digitalocean_database_cluster.db-cluster.database
    project_url = var.project_url
    django_user_password = random_password.password.result
  }
}
