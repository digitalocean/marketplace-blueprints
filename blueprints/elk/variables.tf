variable "do_token" {
  default = ""
}

variable "project_uuid" {
  default = ""
}

variable "droplet_size_slug" {
  default = "s-4vcpu-8gb"
}

variable "tag_list" {
  default = []
  type    = list(string)
}

variable "region" {
  default = "sfo3"
}

variable "project_url" {
  default = ""
}

variable "api_host" {
  default = "https://api.digitalocean.com"
}

variable "provision_kibana_enrollment" {
  type        = bool
  default     = true
  description = "When true, Terraform runs scripts/kibana-enrollment.sh after droplets exist: SSH to Elasticsearch reads KIBANA_ENROLLMENT_TOKEN from /root/.digitalocean_passwords, then runs kibana-setup on Kibana. Requires the machine running terraform apply to reach both droplets as root via SSH (same keys as the DO provider). When false, Kibana is configured with elasticsearch.username/password in cloud-init only."
}
