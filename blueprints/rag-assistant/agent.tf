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

# Resolve model UUIDs from internal names via the public DO API.
# This avoids needing a gRPC client for model resolution.
resource "null_resource" "resolve_models" {
  triggers = {
    default_model   = var.default_model
    embedding_model = var.embedding_model
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      TOKEN="${var.do_token}"
      API="https://api.digitalocean.com/v2/gen-ai"

      # Fetch all models and extract UUIDs by matching the "id" field.
      MODELS=$(curl -sf -H "Authorization: Bearer $TOKEN" "$API/models?per_page=200")

      # Resolve inference model UUID.
      MODEL_UUID=$(echo "$MODELS" | grep -o '"uuid":"[^"]*","name":"[^"]*"[^}]*"id":"${var.default_model}"' | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
      if [ -z "$MODEL_UUID" ]; then
        # Try alternate grep pattern (field order may vary).
        MODEL_UUID=$(echo "$MODELS" | grep -o '"id":"${var.default_model}"[^}]*"uuid":"[^"]*"' | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
      fi

      # Resolve embedding model UUID.
      EMBEDDING_UUID=$(echo "$MODELS" | grep -o '"uuid":"[^"]*","name":"[^"]*"[^}]*"id":"${var.embedding_model}"' | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
      if [ -z "$EMBEDDING_UUID" ]; then
        EMBEDDING_UUID=$(echo "$MODELS" | grep -o '"id":"${var.embedding_model}"[^}]*"uuid":"[^"]*"' | grep -o '"uuid":"[^"]*"' | head -1 | cut -d'"' -f4)
      fi

      echo "{\"model_uuid\":\"$MODEL_UUID\",\"embedding_model_uuid\":\"$EMBEDDING_UUID\"}" > ${path.module}/resolved_models.json
    EOT
  }
}

data "local_file" "resolved_models" {
  depends_on = [null_resource.resolve_models]
  filename   = "${path.module}/resolved_models.json"
}

locals {
  resolved_models = jsondecode(data.local_file.resolved_models.content)
  # Use explicitly provided UUID if set, otherwise use resolved value.
  resolved_model_uuid     = var.model_uuid != "" ? var.model_uuid : local.resolved_models.model_uuid
  resolved_embedding_uuid = var.embedding_model_uuid != "" ? var.embedding_model_uuid : local.resolved_models.embedding_model_uuid
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
        # Remove trailing comma.
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
