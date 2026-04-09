locals {
  # Shared prefix for project name, droplet hostnames, and stack tag (DO naming: lowercase letters, numbers, hyphens).
  resource_name = "${var.stack_name}-${random_string.name_suffix.result}"
}
