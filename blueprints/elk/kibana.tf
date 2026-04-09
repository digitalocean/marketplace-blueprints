locals {
  kibana_user_data = var.provision_kibana_enrollment ? file("${path.module}/templates/kibana-userdata-enrollment.sh") : templatefile("${path.module}/templates/kibana-userdata-password.sh.tftpl", {
    elasticsearch_ipv4 = digitalocean_droplet.elasticsearch.ipv4_address
    kibana_password    = random_password.kibana_password.result
  })
}

resource "digitalocean_droplet" "kibana" {
  image      = "sharklabs-kibana"
  name       = "${local.resource_name}-kibana"
  monitoring = true
  region     = var.region
  size       = var.droplet_size_slug
  ssh_keys   = [for key in data.digitalocean_ssh_keys.keys.ssh_keys : key.fingerprint]
  tags       = concat([digitalocean_tag.stack.id], [for k, v in digitalocean_tag.tags : v.id])

  depends_on = [digitalocean_droplet.elasticsearch]

  connection {
    host    = self.ipv4_address
    user    = "root"
    type    = "ssh"
    agent   = true
    timeout = "2m"
  }

  user_data = local.kibana_user_data
}

resource "null_resource" "kibana_enrollment" {
  count = var.provision_kibana_enrollment ? 1 : 0

  triggers = {
    kibana_id        = digitalocean_droplet.kibana.id
    elasticsearch_id = digitalocean_droplet.elasticsearch.id
  }

  depends_on = [
    digitalocean_droplet.elasticsearch,
    digitalocean_droplet.kibana,
  ]

  provisioner "local-exec" {
    environment = {
      KIBANA_FALLBACK_PASSWORD = nonsensitive(random_password.kibana_password.result)
    }
    command = "${path.module}/scripts/kibana-enrollment.sh ${digitalocean_droplet.elasticsearch.ipv4_address} ${digitalocean_droplet.kibana.ipv4_address}"
  }
}
