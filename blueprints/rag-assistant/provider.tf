terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.81.0"
    }
  }
}

provider "digitalocean" {
  token        = var.do_token
  api_endpoint = var._api_host
}
