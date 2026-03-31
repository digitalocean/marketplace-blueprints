resource "digitalocean_tag" "tag" {
  name = "${var.basename}-resource"
}
