resource "random_string" "name_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "kibana_password" {
  length  = 24
  special = false
}

resource "random_password" "logstash_password" {
  length  = 24
  special = false
}
