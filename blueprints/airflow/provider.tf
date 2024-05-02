terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
  api_endpoint = var._api_host
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}
