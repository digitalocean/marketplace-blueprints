resource "digitalocean_droplet" "airflow" {
  image      = var.droplet_image
  name       = "${local.resource_name}-droplet"
  monitoring = true
  region     = var.region
  size       = var.droplet_size_slug
  ssh_keys   = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  user_data  = templatefile("${path.module}/files/cloud-init.yaml", local.cloud_init_vars)
  tags       = [digitalocean_tag.tag.id]

  connection {
    host    = self.ipv4_address
    user    = "root"
    type    = "ssh"
    agent   = true
    timeout = "2m"
  }
}
