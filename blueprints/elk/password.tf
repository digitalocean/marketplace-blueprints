resource "random_password" "kibana_password" {
  length = 24
  special = false
}

resource "random_password" "logstash_password" {
  length = 24
  special = false
}