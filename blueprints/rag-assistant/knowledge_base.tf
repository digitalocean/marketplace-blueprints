# Knowledge base for RAG document retrieval.
# Seeded with a placeholder DO docs page. Customer adds their own documents post-deploy.
# NOTE: Knowledge bases currently only support the tor1 region.
resource "digitalocean_gradientai_knowledge_base" "kb" {
  name                 = "${local.resource_name}-kb"
  project_id           = local.active_project_id
  region               = var.region
  embedding_model_uuid = var.embedding_model_uuid
  tags                 = [digitalocean_tag.tag.name]

  datasources {
    web_crawler_data_source {
      base_url        = "https://docs.digitalocean.com/products/genai-platform/getting-started/quickstart/"
      crawling_option = "PATH"
    }
  }
}
