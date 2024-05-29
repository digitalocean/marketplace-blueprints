resource "digitalocean_droplet" "airflow" {
  image  = var._image
  name   = var.droplet_name
  monitoring = true
  region = var.region
  size   = var.droplet_size_slug
  ssh_keys = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  user_data = data.template_file.cloud-init-yaml.rendered
  tags = [for k, v in digitalocean_tag.tags : v.id]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    agent = true
    timeout = "2m"
  }
}
