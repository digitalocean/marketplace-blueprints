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

  # Guardrails
  agent_guardrail {
    name             = "Jailbreak Detection"
    type             = "GUARDRAIL_TYPE_JAILBREAK"
    priority         = 1
    default_response = "I'm unable to process that request."
    description      = "Prevents jailbreak and prompt injection attempts."
    is_default       = true
  }

  agent_guardrail {
    name             = "Content Moderation"
    type             = "GUARDRAIL_TYPE_CONTENT_MODERATION"
    priority         = 2
    default_response = "I'm unable to respond to that type of content."
    description      = "Filters harmful, toxic, or inappropriate content."
    is_default       = true
  }

  agent_guardrail {
    name             = "Sensitive Data Detection"
    type             = "GUARDRAIL_TYPE_SENSITIVE_DATA"
    priority         = 3
    default_response = "I've detected sensitive information in your request and cannot process it."
    description      = "Detects and blocks PII and other sensitive data."
    is_default       = true
  }
}
