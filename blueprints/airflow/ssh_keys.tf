data "digitalocean_ssh_keys" "keys" {
  count = length(var.ssh_key_ids) == 0 ? 1 : 0
  sort {
    key       = "name"
    direction = "asc"
  }
}

locals {
  ssh_keys = length(var.ssh_key_ids) > 0 ? var.ssh_key_ids : [for key in data.digitalocean_ssh_keys.keys[0].ssh_keys : key.id]
}
