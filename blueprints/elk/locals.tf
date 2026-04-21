locals {
  # Shared prefix for droplet hostnames and stack tag (DO naming: lowercase letters, numbers, hyphens).
  resource_name = "${var.stack_name}-${random_string.name_suffix.result}"
  # Project display name — uses project_name if provided, otherwise stack_name.
  project_display_name = var.project_name != "" ? var.project_name : var.stack_name
}
