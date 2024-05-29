
// API CONFIGURATION

variable "do_token" {
  default = "dop_v1_your_token"
}
variable "_api_host" {
  default = "https://api.digitalocean.com"
}

// PROJECT CONFIGURATION

variable "project_uuid" {
  default = ""
}
variable "project_url" {
  default = ""
}
variable "tag_list" {
  default = ["blueprint-resource"]
  type = list(string)
}
variable "region" {
  default = "sfo3"
}

//SPACES CONFIGURATION

variable "spaces_access_id" {
  default = "your_spaces_access_key_here"
}
variable "spaces_secret_key" {
  default = "your_spaces_secret_key_here"
}
variable "spaces_bucket_name" {
  default = "airflow-bucket"
}
variable "spaces_host"{
  default = "https://sfo3.digitaloceanspaces.com"
}
variable "_spaces_connection_id"{
  default = "spaces_conn"
}
variable "_spaces_connection_type"{
  default = "aws"
}

// DROPLET CONFIGURATION

variable "droplet_name" {
  default = "airflow-droplet"
}
variable "droplet_size_slug" {
  default = "s-4vcpu-8gb"
}
variable "_image" {
  // Can be either image slug or ID
  default = "airflow-22-04"
}

// DATABASE CONFIGURATION

variable "db_node_count" {
  default = 1
}
variable "db_cluster_name" {
  default = "airflow-stack-db-cluster"
}
variable "db_size_slug" {
  default = "db-s-1vcpu-2gb"
}
variable "_db_engine" {
  default = "pg"
}
variable "_db_protocol" {
  default = "postgresql"
}
variable "_db_engine_version" {
  default = "16"
}

// KEYSTORE CONFIGURATION

variable "keystore_node_count" {
  default = 1
}
variable "keystore_name" {
  default = "airflow-stack-kv-cluster"
}
variable "keystore_size_slug" {
  default = "db-s-1vcpu-2gb"
}

variable "_keystore_connection_id"{
  default = "redis_conn"
}
variable "_keystore_engine" {
  default = "redis"
}
variable "_keystore_protocol" {
  default = "redis"
}
variable "_keystore_engine_version" {
  default = "7"
}


