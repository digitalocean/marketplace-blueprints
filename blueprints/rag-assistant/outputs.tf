output "chat_ui_url" {
  value       = digitalocean_app.chat_ui.live_url
  description = "URL of the chat UI application."
}

output "agent_uuid" {
  value       = digitalocean_gradientai_agent.rag_agent.id
  description = "UUID of the managed RAG agent."
}

output "knowledge_base_uuid" {
  value       = digitalocean_gradientai_knowledge_base.kb.id
  description = "UUID of the knowledge base. Upload documents via the DO console."
}

output "project_id" {
  value       = local.active_project_id
  description = "Project ID containing all resources."
}
