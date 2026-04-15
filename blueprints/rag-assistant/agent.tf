# Resolve model UUIDs from internal names via the public DO API.
data "external" "resolve_models" {
  program = ["sh", "-c", <<-EOT
    TOKEN="${var.do_token}"
    MODELS=$(curl -sf -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/gen-ai/models?per_page=200" 2>/dev/null || echo '{"models":[]}')

    # Extract UUID for default model by matching the "id" field.
    MODEL_UUID=""
    MODEL_LINE=$(echo "$MODELS" | tr ',' '\n' | grep -A50 "\"id\":\"${var.default_model}\"" | grep '"uuid"' | head -1)
    if [ -n "$MODEL_LINE" ]; then
      MODEL_UUID=$(echo "$MODEL_LINE" | sed 's/.*"uuid":"\([^"]*\)".*/\1/')
    fi

    # Extract UUID for embedding model.
    EMBED_UUID=""
    EMBED_LINE=$(echo "$MODELS" | tr ',' '\n' | grep -A50 "\"id\":\"${var.embedding_model}\"" | grep '"uuid"' | head -1)
    if [ -n "$EMBED_LINE" ]; then
      EMBED_UUID=$(echo "$EMBED_LINE" | sed 's/.*"uuid":"\([^"]*\)".*/\1/')
    fi

    echo "{\"model_uuid\":\"$MODEL_UUID\",\"embedding_model_uuid\":\"$EMBED_UUID\"}"
  EOT
  ]
}

locals {
  resolved_model_uuid     = var.model_uuid != "" ? var.model_uuid : data.external.resolve_models.result.model_uuid
  resolved_embedding_uuid = var.embedding_model_uuid != "" ? var.embedding_model_uuid : data.external.resolve_models.result.embedding_model_uuid
}

# Managed agent for RAG interactions.
resource "digitalocean_gradientai_agent" "rag_agent" {
  name        = "${local.resource_name}-agent"
  description = "RAG Assistant powered by serverless inference with knowledge base retrieval and guardrails."
  # NOTE: GenAI platform is currently only available in tor1.
  region     = "tor1"
  project_id = local.active_project_id

  model_uuid  = local.resolved_model_uuid
  instruction = var.agent_instruction
  temperature = var.agent_temperature
  max_tokens  = var.agent_max_tokens
  k           = var.agent_k

  provide_citations = true
  retrieval_method  = "RETRIEVAL_METHOD_SUB_QUERIES"
}

# Post-creation: attach KB and guardrails.
# The terraform provider cannot attach these on create (godo SDK limitation).
resource "null_resource" "agent_post_setup" {
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
      set -e
      AGENT_ID="${digitalocean_gradientai_agent.rag_agent.id}"
      KB_ID="${digitalocean_gradientai_knowledge_base.kb.id}"
      TOKEN="${var.do_token}"
      API="https://api.digitalocean.com/v2/gen-ai"

      # 1. Wait for KB indexing to complete (required before attachment).
      echo "Waiting for KB indexing to complete..."
      for i in $(seq 1 60); do
        RESP=$(curl -sf -H "Authorization: Bearer $TOKEN" "$API/knowledge_bases/$KB_ID" 2>/dev/null || echo "")
        if echo "$RESP" | grep -q "INDEX_JOB_STATUS_COMPLETED"; then
          echo "KB indexing complete"
          break
        fi
        echo "  Waiting... (attempt $i/60)"
        sleep 10
      done

      # 2. Attach KB to agent.
      echo "Attaching KB to agent..."
      curl -sf -X POST \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' \
        "$API/agents/$AGENT_ID/knowledge_bases/$KB_ID"
      echo "KB attached"

      # 3. Attach guardrails to agent.
      GUARDRAILS=""
      %{if var.guardrail_jailbreak_uuid != ""~}
      GUARDRAILS="$GUARDRAILS{\"guardrail_uuid\":\"${var.guardrail_jailbreak_uuid}\",\"priority\":1},"
      %{endif~}
      %{if var.guardrail_content_mod_uuid != ""~}
      GUARDRAILS="$GUARDRAILS{\"guardrail_uuid\":\"${var.guardrail_content_mod_uuid}\",\"priority\":2},"
      %{endif~}
      %{if var.guardrail_sensitive_data_uuid != ""~}
      GUARDRAILS="$GUARDRAILS{\"guardrail_uuid\":\"${var.guardrail_sensitive_data_uuid}\",\"priority\":3},"
      %{endif~}

      if [ -n "$GUARDRAILS" ]; then
        GUARDRAILS=$(echo "$GUARDRAILS" | sed 's/,$//')
        echo "Attaching guardrails..."
        curl -sf -X POST \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d "{\"guardrails\":[$GUARDRAILS]}" \
          "$API/agents/$AGENT_ID/guardrails"
        echo "Guardrails attached"
      fi
    EOT
  }
}
