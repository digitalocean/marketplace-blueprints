resource "digitalocean_spaces_bucket" "spaces_bucket" {
  name   = "${local.resource_name}"
  region = var.region
}

resource "digitalocean_spaces_key" "airflow_key" {
  name = "${local.resource_name}-spaces-key"

  # Scopes the generated key to this specific bucket
  grant {
    bucket     = digitalocean_spaces_bucket.spaces_bucket.name
    permission = "readwrite" # Accepts "read" or "readwrite" for specific buckets
  }
}