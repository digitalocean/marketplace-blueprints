# Post-creation setup: create API key, fetch deployment URL, and attach KB.
# The terraform provider doesn't fully support these operations inline.
resource "null_resource" "agent_setup" {
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

      # Wait for agent deployment to be ready
      echo "Waiting for agent deployment..."
      for i in $(seq 1 30); do
        STATUS=$(curl -sf -H "Authorization: Bearer $TOKEN" "$API/agents/$AGENT_ID" | python3 -c "import json,sys; print(json.load(sys.stdin)['agent']['deployment']['status'])" 2>/dev/null || echo "unknown")
        if [ "$STATUS" = "STATUS_RUNNING" ]; then
          echo "Agent deployment is running"
          break
        fi
        echo "  Status: $STATUS (attempt $i/30)"
        sleep 5
      done

      # Attach knowledge base
      echo "Attaching knowledge base..."
      curl -sf -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
        "$API/agents/$AGENT_ID/knowledge_bases/$KB_ID" || echo "KB attachment failed (may already be attached)"

      # Create API key
      echo "Creating API key..."
      KEY_RESP=$(curl -sf -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
        -d '{"name":"chat-ui-key"}' "$API/agents/$AGENT_ID/api_keys")
      SECRET_KEY=$(echo "$KEY_RESP" | python3 -c "import json,sys; print(json.load(sys.stdin)['api_key_info']['secret_key'])")

      # Get deployment URL
      echo "Fetching deployment URL..."
      AGENT_RESP=$(curl -sf -H "Authorization: Bearer $TOKEN" "$API/agents/$AGENT_ID")
      DEPLOY_URL=$(echo "$AGENT_RESP" | python3 -c "import json,sys; print(json.load(sys.stdin)['agent']['deployment']['url'])")

      echo "Agent endpoint: $DEPLOY_URL"
      echo "{\"secret_key\": \"$SECRET_KEY\", \"deploy_url\": \"$DEPLOY_URL\"}" > ${path.module}/agent_config.json
    EOT
  }
}

data "local_file" "agent_config" {
  depends_on = [null_resource.agent_setup]
  filename   = "${path.module}/agent_config.json"
}

locals {
  agent_config     = jsondecode(data.local_file.agent_config.content)
  agent_api_key    = local.agent_config.secret_key
  agent_deploy_url = local.agent_config.deploy_url
}
