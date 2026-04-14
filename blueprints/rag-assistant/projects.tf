resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  resource_name = "${var.basename}-${random_string.suffix.result}"
}

# Create a new project if project_uuid is not provided.
resource "digitalocean_project" "rag_assistant" {
  count       = var.project_uuid == "" ? 1 : 0
  name        = local.resource_name
  purpose     = "RAG Assistant"
  environment = "Development"
}

# Use existing project if project_uuid is provided.
data "digitalocean_project" "existing" {
  count = var.project_uuid != "" ? 1 : 0
  id    = var.project_uuid
}

locals {
  active_project_id = var.project_uuid == "" ? digitalocean_project.rag_assistant[0].id : data.digitalocean_project.existing[0].id
}

resource "digitalocean_project_resources" "project_resources" {
  project = local.active_project_id
  resources = [
    digitalocean_app.chat_ui.urn,
  ]
}
