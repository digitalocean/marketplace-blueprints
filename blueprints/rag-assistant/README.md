# Welcome to the DigitalOcean RAG Assistant Terraform Stack!

This stack deploys a fully functional Retrieval-Augmented Generation (RAG) assistant on DigitalOcean, including:

- A **managed GenAI agent** with serverless inference for question answering.
- A **Knowledge Base** (KBaaS) for document storage and semantic retrieval.
- An **App Platform** service hosting a chat UI that proxies requests to the agent.
- **Guardrails** for jailbreak detection, content moderation, and sensitive data protection.
- A **DigitalOcean project** to group all provisioned resources.

The agent, knowledge base, chat UI, and guardrails are wired together out of the box.

## How to use this blueprint?

Learn [here](../../README.md#how-to-use-digitalocean-blueprints) how to use this blueprint.

## Architecture

```
User  ──>  Chat UI (App Platform)
               │
               ▼
         Managed Agent  ──>  Guardrails (jailbreak / content / PII)
               │
               ▼
         Knowledge Base  ──>  Embedding Model (Qwen3 0.6B)
               │
               ▼
       Serverless Inference (configurable model)
               │
               ▼
           Response
```

The query flow works as follows:

1. The user sends a message through the Chat UI.
2. The App Platform service forwards the message to the managed agent's OpenAI-compatible endpoint.
3. The agent runs the query through attached guardrails (jailbreak, content moderation, sensitive data).
4. The agent retrieves relevant document chunks from the Knowledge Base using semantic search.
5. Retrieved context is assembled into a prompt and sent to the serverless inference model.
6. The response passes back through guardrails and is returned to the user.

## Getting started

After the stack is deployed, allow 2-3 minutes for the knowledge base to finish indexing its initial data source and for the App Platform build to complete.

### 1. Access the Chat UI

The chat UI URL is available in the Terraform outputs (`chat_ui_url`). Open it in your browser to see the assistant interface.

### 2. Upload your documents

The knowledge base is seeded with a placeholder DigitalOcean docs page. To use your own data:

1. Go to the [DigitalOcean console](https://cloud.digitalocean.com/).
2. Navigate to **GenAI Platform > Knowledge Bases**.
3. Select the knowledge base created by this stack (named `<basename>-<suffix>-kb`).
4. Add your documents — supported formats include web URLs, PDFs, and plain text.
5. Wait for indexing to complete, then ask the assistant questions about your content.

### 3. Ask questions

Use the chat interface to ask questions. The assistant will search your knowledge base documents and provide grounded answers with citations when available.

## Terraform variables

| Variable | Default | Description |
|---|---|---|
| `do_token` | *(required)* | DigitalOcean API token |
| `project_uuid` | `""` | Existing project UUID (leave empty to create a new project) |
| `basename` | `rag-assistant` | Base name used to auto-generate resource names |
| `project_name` | `""` | Display name for the project (defaults to `basename`) |
| `region` | `nyc3` | DigitalOcean region for App Platform resources |
| `default_model` | `nvidia-nemotron-3-super-120b` | Serverless inference model name |
| `model_uuid` | *(required)* | UUID of the inference model (resolved by do-terraform) |
| `embedding_model` | `qwen3-embedding-0.6b` | Embedding model name |
| `embedding_model_uuid` | *(required)* | UUID of the embedding model (resolved by do-terraform) |
| `app_instance_size` | `apps-s-1vcpu-1gb` | App Platform instance size slug |
| `agent_instruction` | *(see variables.tf)* | System instruction for the agent |
| `agent_temperature` | `0` | Inference temperature (0 = deterministic) |
| `agent_max_tokens` | `4096` | Maximum tokens in the agent response |
| `agent_k` | `5` | Number of KB documents to retrieve per query |
| `guardrail_jailbreak_uuid` | `""` | UUID of the jailbreak detection guardrail |
| `guardrail_content_mod_uuid` | `""` | UUID of the content moderation guardrail |
| `guardrail_sensitive_data_uuid` | `""` | UUID of the sensitive data detection guardrail |

## Terraform outputs

| Output | Description |
|---|---|
| `chat_ui_url` | URL of the deployed chat UI application |
| `agent_uuid` | UUID of the managed RAG agent |
| `knowledge_base_uuid` | UUID of the knowledge base |
| `project_id` | Project ID containing all resources |
| `app_platform_id` | App Platform resource ID |
| `agent_id` | GenAI agent resource ID |
| `knowledge_base_id` | Knowledge base resource ID |

## Stack details

- **GenAI region**: The agent and knowledge base are deployed to `tor1` (the only region currently supporting the GenAI platform).
- **App Platform region**: Configurable via the `region` variable (default `nyc3`).
- **Inference**: Serverless — no GPU instances to manage. The model is configurable via model presets when deployed through do-terraform.
- **Embeddings**: Qwen3 0.6B is used by default for document embedding.
- **Guardrails**: Jailbreak detection, content moderation, and sensitive data protection are attached post-creation via the DO API (terraform provider limitation).
- **KB indexing**: A `null_resource` provisioner waits up to 10 minutes for knowledge base indexing to complete before attaching it to the agent.
- **Chat UI**: A Python FastAPI application deployed on App Platform. It discovers the agent endpoint and creates an API key at startup.
- **Resource naming**: All resources are suffixed with a random 4-character string to avoid naming collisions.

## Chat UI

The chat UI is a lightweight FastAPI application located in `chat-ui/`. It:

- Serves a single-page web interface with a conversational chat layout.
- Proxies messages to the managed agent's OpenAI-compatible chat completions endpoint.
- Auto-discovers the agent's deployment URL and creates an API key on startup.
- Maintains conversation history for multi-turn interactions.

### Local development

To run the chat UI locally (requires a deployed agent):

```bash
cd chat-ui
pip install -r requirements.txt
export AGENT_UUID=<your-agent-uuid>
export DO_API_TOKEN=<your-token>
export AGENT_NAME="RAG Assistant"
uvicorn main:app --host 0.0.0.0 --port 8080
```

## Security

- The `do_token` variable is marked as sensitive and will not appear in Terraform plan output.
- The agent API key is injected as a `SECRET` environment variable in App Platform.
- Guardrails provide defense-in-depth against prompt injection, toxic content, and PII leakage.
- The chat UI does not store conversation history server-side; all history is held in the browser session.
