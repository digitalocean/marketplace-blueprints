// API CONFIGURATION

variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "_api_host" {
  type    = string
  default = "https://api.digitalocean.com"
}

// PROJECT CONFIGURATION

variable "project_uuid" {
  type        = string
  description = "Existing project UUID (leave empty to create new project)"
  default     = ""
}

variable "basename" {
  type        = string
  description = "The base name used to auto-generate resource names."
  default     = "data-workflow-starter-kit"
}

variable "region" {
  type        = string
  description = "DigitalOcean region"
  default     = "sfo3"
}

//SPACES CONFIGURATION

variable "spaces_access_id" {
  type        = string
  description = "Spaces access key ID (optional - if not provided, Spaces bucket won't be created)"
  default     = ""
}

variable "spaces_secret_key" {
  type        = string
  description = "Spaces secret key (optional - if not provided, Spaces bucket won't be created)"
  default     = ""
  sensitive   = true
}

variable "_spaces_connection_id" {
  type    = string
  default = "spaces_conn"
}

variable "_spaces_connection_type" {
  type    = string
  default = "aws"
}

// DROPLET CONFIGURATION

variable "droplet_size_slug" {
  type        = string
  description = "Droplet size"
  default     = "s-4vcpu-8gb"
}

variable "droplet_image" {
  type        = string
  description = "Droplet image slug"
  default     = "airflow"
}

// DATABASE CONFIGURATION

variable "db_node_count" {
  type        = number
  description = "Number of database nodes"
  default     = 1
}

variable "db_size_slug" {
  type        = string
  description = "Database cluster size"
  default     = "db-s-1vcpu-2gb"
}

variable "_db_engine" {
  type    = string
  default = "pg"
}

variable "_db_protocol" {
  type    = string
  default = "postgresql"
}

variable "_db_engine_version" {
  type    = string
  default = "16"
}

// KEYSTORE CONFIGURATION

variable "keystore_node_count" {
  type        = number
  description = "Number of keystore nodes"
  default     = 1
}

variable "keystore_size_slug" {
  type        = string
  description = "Keystore cluster size"
  default     = "db-s-1vcpu-2gb"
}

variable "_keystore_connection_id" {
  type    = string
  default = "valkey_conn"
}

variable "_keystore_engine" {
  type    = string
  default = "valkey"
}

variable "_keystore_engine_version" {
  type    = string
  default = "8"
}

variable "_keystore_protocol" {
  type    = string
  default = "rediss"
}
