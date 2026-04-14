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
        STATUS=$(curl -sf -H "Authorization: Bearer $TOKEN" "$API/knowledge_bases/$KB_ID" | python3 -c "import json,sys; print(json.load(sys.stdin)['knowledge_base'].get('last_indexing_job',{}).get('status','unknown'))" 2>/dev/null || echo "unknown")
        if [ "$STATUS" = "INDEX_JOB_STATUS_COMPLETED" ]; then
          echo "KB indexing complete"
          break
        fi
        echo "  KB status: $STATUS (attempt $i/60)"
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
      GUARDRAILS='[]'
      %{if var.guardrail_jailbreak_uuid != ""~}
      GUARDRAILS=$(echo "$GUARDRAILS" | python3 -c "import json,sys; g=json.load(sys.stdin); g.append({'guardrail_uuid':'${var.guardrail_jailbreak_uuid}','priority':1}); print(json.dumps(g))")
      %{endif~}
      %{if var.guardrail_content_mod_uuid != ""~}
      GUARDRAILS=$(echo "$GUARDRAILS" | python3 -c "import json,sys; g=json.load(sys.stdin); g.append({'guardrail_uuid':'${var.guardrail_content_mod_uuid}','priority':2}); print(json.dumps(g))")
      %{endif~}
      %{if var.guardrail_sensitive_data_uuid != ""~}
      GUARDRAILS=$(echo "$GUARDRAILS" | python3 -c "import json,sys; g=json.load(sys.stdin); g.append({'guardrail_uuid':'${var.guardrail_sensitive_data_uuid}','priority':3}); print(json.dumps(g))")
      %{endif~}

      if [ "$GUARDRAILS" != "[]" ]; then
        echo "Attaching guardrails..."
        curl -sf -X POST \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d "{\"guardrails\":$GUARDRAILS}" \
          "$API/agents/$AGENT_ID/guardrails"
        echo "Guardrails attached"
      fi
    EOT
  }
}
