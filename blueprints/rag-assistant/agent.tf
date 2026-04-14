# Managed agent with knowledge base and guardrails.
# The chat UI calls this agent's API for all RAG interactions.
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
resource "digitalocean_gradientai_agent_knowledge_base_attachment" "kb_attachment" {
  agent_uuid          = digitalocean_gradientai_agent.rag_agent.id
  knowledge_base_uuid = digitalocean_gradientai_knowledge_base.kb.id
}
