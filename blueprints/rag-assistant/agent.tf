# Managed agent for RAG interactions.
resource "digitalocean_gradientai_agent" "rag_agent" {
  name        = "${local.resource_name}-agent"
  description = "RAG Assistant powered by serverless inference with knowledge base retrieval and guardrails."
  # NOTE: GenAI platform is currently only available in tor1.
  region     = "tor1"
  project_id = local.active_project_id

  model_uuid  = var.model_uuid
  instruction = var.agent_instruction
  temperature = var.agent_temperature
  max_tokens  = var.agent_max_tokens
  k           = var.agent_k

  provide_citations = true
  retrieval_method  = "RETRIEVAL_METHOD_SUB_QUERIES"
}

# Attach knowledge base to the agent.
# NOTE: The terraform digitalocean_gradientai_agent_knowledge_base_attachment resource
# uses the singular API endpoint which returns 400. The plural endpoint works.
# Using null_resource as a workaround until the provider/godo SDK is fixed.
resource "null_resource" "kb_attachment" {
  depends_on = [
    digitalocean_gradientai_agent.rag_agent,
    digitalocean_gradientai_knowledge_base.kb,
  ]

  triggers = {
    agent_id = digitalocean_gradientai_agent.rag_agent.id
    kb_id    = digitalocean_gradientai_knowledge_base.kb.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -sf -X POST \
        -H "Authorization: Bearer ${var.do_token}" \
        -H "Content-Type: application/json" \
        -d '{"knowledge_base_uuids":["${digitalocean_gradientai_knowledge_base.kb.id}"]}' \
        "https://api.digitalocean.com/v2/gen-ai/agents/${digitalocean_gradientai_agent.rag_agent.id}/knowledge_bases"
    EOT
  }
}
