resource "digitalocean_spaces_bucket" "spaces_bucket" {
  name   = var.spaces_bucket_name
  region = var.region
}