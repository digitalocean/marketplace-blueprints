variable "do_token" {}

variable "project_uuid" {
  default = ""
}

variable "droplet_count" {
  default = 3
}
variable "droplet_names" {
  default = ["django-stack-droplet-0", "django-stack-droplet-1", "django-stack-droplet-2"]
  type = list(string)
}
variable "image" { 
  // Can be either image slug or ID
  default = "django-20-04" // It is actually 22-04, it's just old slug sticking around
}
variable "droplet_size_slug" {
  default = "s-4vcpu-8gb"
}

variable "lb_count" {
  default = 1
}

variable "lb_name" {
  default = "django-stack-lb"
}
variable "create_db" {
  default = false
}
variable "db_engine" {
  default = "pg"
}
variable "db_engine_version" {
  default = "12"
}
variable "db_cluster_name" {
  default = "django-stack-db-cluster"
}
variable "db_size_slug" {
  default = "db-s-1vcpu-2gb"
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
