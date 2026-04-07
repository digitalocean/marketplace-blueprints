# Spaces bucket - only created if Spaces credentials are provided
resource "digitalocean_spaces_bucket" "spaces_bucket" {
  count  = var.spaces_access_id != "" && var.spaces_secret_key != "" ? 1 : 0
  name   = "${local.resource_name}-bucket"
  region = var.region
}

# Note: Spaces keys can be created separately via DigitalOcean control panel or CLI
# and provided as variables to enable bucket creation
