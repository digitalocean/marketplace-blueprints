// =============================================================================
// API CONFIGURATION
// =============================================================================

variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "_api_host" {
  type        = string
  default     = "https://api.digitalocean.com"
  description = "DigitalOcean API endpoint (internal use)"
}

// =============================================================================
// PROJECT CONFIGURATION
// =============================================================================

variable "project_uuid" {
  type        = string
  default     = ""
  description = "Existing project UUID (leave empty to create new project)"
}

variable "basename" {
  type        = string
  default     = "rag-assistant"
  description = "The base name used to auto-generate resource names."
}

variable "region" {
  type        = string
  default     = "nyc3"
  description = "DigitalOcean region for all resources."
}

// =============================================================================
// MODEL CONFIGURATION
// =============================================================================

variable "default_model" {
  type        = string
  default     = "nvidia-nemotron-3-super-120b"
  description = "Serverless inference model internal name (for reference/display only)."
}

variable "model_uuid" {
  type        = string
  description = "UUID of the serverless inference model. Resolved by the do-terraform service from the model internal name."
}

variable "embedding_model" {
  type        = string
  default     = "qwen3-embedding-0.6b"
  description = "Embedding model internal name (for reference/display only)."
}

variable "embedding_model_uuid" {
  type        = string
  description = "UUID of the embedding model. Resolved by the do-terraform service from the model internal name."
}

// =============================================================================
// APP PLATFORM CONFIGURATION
// =============================================================================

variable "app_instance_size" {
  type        = string
  default     = "apps-s-1vcpu-1gb"
  description = "App Platform instance size slug for the chat UI."
}

variable "_app_source_repo" {
  type        = string
  default     = "digitalocean/marketplace-blueprints"
  description = "GitHub repo for the app source code."
}

variable "_app_source_branch" {
  type        = string
  default     = "main"
  description = "Git branch for the app source code."
}

// =============================================================================
// AGENT CONFIGURATION
// =============================================================================

variable "agent_instruction" {
  type        = string
  default     = "You are a helpful RAG assistant. Answer questions using the knowledge base context provided. If you don't know the answer, say so honestly."
  description = "System instruction for the managed agent."
}

variable "agent_temperature" {
  type        = number
  default     = 0
  description = "Temperature for inference (0.0 = deterministic, 1.0 = creative). Supplied by model preset."
}

variable "agent_max_tokens" {
  type        = number
  default     = 4096
  description = "Maximum tokens in the agent's response. Supplied by model preset."
}

variable "agent_k" {
  type        = number
  default     = 5
  description = "Number of knowledge base documents to retrieve per query."
}
