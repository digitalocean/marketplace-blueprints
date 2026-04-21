variable "do_token" {
  type        = string
  sensitive   = true
  description = "DigitalOcean API token. Pass at apply time, e.g. terraform apply -var=\"do_token=$DIGITALOCEAN_TOKEN\" or export TF_VAR_do_token=..."
}

variable "stack_name" {
  type        = string
  default     = "elk"
  description = "Prefix for the auto-generated project name, droplet hostnames, and primary stack tag; a random suffix is appended (e.g. elk-a1b2c3)."
}

variable "project_name" {
  type        = string
  default     = ""
  description = "Display name for the DO project. Defaults to stack_name if empty."
}

variable "droplet_size_slug" {
  default = "s-4vcpu-8gb"
}

variable "tag_list" {
  type        = list(string)
  default     = []
  description = "Optional extra DigitalOcean tags (in addition to the auto-generated stack tag)."
}

variable "region" {
  default = "sfo3"
}

variable "api_host" {
  default = "https://api.digitalocean.com"
}

variable "provision_kibana_enrollment" {
  type        = bool
  default     = true
  description = "When true, Terraform runs scripts/kibana-enrollment.sh after droplets exist: SSH to Elasticsearch reads KIBANA_ENROLLMENT_TOKEN from /root/.digitalocean_passwords, then runs kibana-setup on Kibana. Requires the machine running terraform apply to reach both droplets as root via SSH (same keys as the DO provider). When false, Kibana is configured with elasticsearch.username/password in cloud-init only."
}
