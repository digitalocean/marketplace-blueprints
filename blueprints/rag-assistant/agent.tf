# Managed agent with knowledge base and guardrails.
# The chat UI calls this agent's API for all RAG interactions.
resource "digitalocean_gradientai_agent" "rag_agent" {
  name        = "${local.resource_name}-agent"
  description = "RAG Assistant"
  # NOTE: GenAI platform is currently only available in tor1.
  region     = "tor1"
  project_id = local.active_project_id

  model_uuid  = var.model_uuid
  instruction = var.agent_instruction
}
