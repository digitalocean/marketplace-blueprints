# Create an API key for the agent and fetch its deployment URL.
# The terraform provider doesn't expose these computed values,
# so we use local-exec to call the DO API directly.
resource "null_resource" "agent_setup" {
  depends_on = [digitalocean_gradientai_agent.rag_agent]

  triggers = {
    agent_id = digitalocean_gradientai_agent.rag_agent.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Create an API key for the agent
      KEY_RESP=$(curl -sf -X POST \
        -H "Authorization: Bearer ${var.do_token}" \
        -H "Content-Type: application/json" \
        -d '{"name":"chat-ui-key"}' \
        "https://api.digitalocean.com/v2/gen-ai/agents/${digitalocean_gradientai_agent.rag_agent.id}/api_keys")
      SECRET_KEY=$(echo "$KEY_RESP" | python3 -c "import json,sys; print(json.load(sys.stdin)['api_key_info']['secret_key'])")

      # Get the agent deployment URL
      AGENT_RESP=$(curl -sf \
        -H "Authorization: Bearer ${var.do_token}" \
        "https://api.digitalocean.com/v2/gen-ai/agents/${digitalocean_gradientai_agent.rag_agent.id}")
      DEPLOY_URL=$(echo "$AGENT_RESP" | python3 -c "import json,sys; print(json.load(sys.stdin)['agent']['deployment']['url'])")

      # Write to a file for the data source to read
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
