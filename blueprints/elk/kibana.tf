resource "digitalocean_droplet" "kibana" {
  image      = "sharklabs-kibana"
  name       = "${local.resource_name}-kibana"
  monitoring = true
  region     = var.region
  size       = var.droplet_size_slug
  ssh_keys   = local.ssh_keys
  tags       = concat([digitalocean_tag.stack.id], [for k, v in digitalocean_tag.tags : v.id])

  depends_on = [digitalocean_droplet.elasticsearch]

  connection {
    host    = self.ipv4_address
    user    = "root"
    type    = "ssh"
    agent   = true
    timeout = "2m"
  }

  user_data = templatefile("${path.module}/templates/kibana-userdata-password.sh.tftpl", {
    elasticsearch_ipv4 = digitalocean_droplet.elasticsearch.ipv4_address
    kibana_password      = random_password.kibana_password.result
  })
}
