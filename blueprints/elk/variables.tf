variable "do_token" {}
variable "ssh_key_ids" {
  default = []
  type = list(number)
}

variable "project_uuid" {
  default = ""
}

variable "droplet_size_slug" {
  default = "s-4vcpu-8gb"
}

variable "tag_list" {
  default = []
  type = list(string)
}

variable "region" {
  default = "nyc3"
}

variable "project_url" {
  default = ""
}

variable "api_host" {
  default = "https://api.digitalocean.com"
}
