resource "digitalocean_tag" "tags" {
  for_each = toset(var.tag_list)
  name = each.value
}
