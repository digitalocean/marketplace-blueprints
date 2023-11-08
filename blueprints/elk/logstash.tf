resource "digitalocean_droplet" "logstash" {
  image  = "sharklabs-logstash"
  name   = "elk-stack-logstash"
  region = var.region
  size   = var.droplet_size_slug
  ssh_keys = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  tags = [for k, v in digitalocean_tag.tags : v.id]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    agent = true
    timeout = "2m"
  }
}
