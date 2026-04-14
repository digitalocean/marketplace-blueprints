"""RAG Assistant Chat UI — a lightweight FastAPI app that proxies chat
messages to a DigitalOcean managed GenAI agent and serves a simple web
interface.

Environment variables (injected by terraform via App Platform):
    AGENT_UUID   — UUID of the managed agent
    DO_API_TOKEN — DigitalOcean API token (secret)
    AGENT_NAME   — Display name of the agent (optional)
"""

import os
from pathlib import Path

import httpx
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, StreamingResponse

app = FastAPI(title="RAG Assistant")

AGENT_UUID = os.environ["AGENT_UUID"]
DO_API_TOKEN = os.environ["DO_API_TOKEN"]
AGENT_NAME = os.environ.get("AGENT_NAME", "RAG Assistant")
DO_API_BASE = os.environ.get("DO_API_BASE", "https://api.digitalocean.com")

CHAT_ENDPOINT = f"{DO_API_BASE}/v2/gen-ai/agents/{AGENT_UUID}/chat"

# Serve the static HTML chat page.
INDEX_HTML = (Path(__file__).parent / "static" / "index.html").read_text()


@app.get("/", response_class=HTMLResponse)
async def index():
    """Serve the chat UI."""
    return INDEX_HTML.replace("{{AGENT_NAME}}", AGENT_NAME)


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/api/chat")
async def chat(request: Request):
    """Proxy a chat message to the managed agent and stream the response."""
    body = await request.json()
    message = body.get("message", "")
    thread_id = body.get("thread_id")

    payload = {"message": message}
    if thread_id:
        payload["thread_id"] = thread_id

    headers = {
        "Authorization": f"Bearer {DO_API_TOKEN}",
        "Content-Type": "application/json",
    }

    async def stream_response():
        async with httpx.AsyncClient(timeout=120.0) as client:
            async with client.stream(
                "POST", CHAT_ENDPOINT, json=payload, headers=headers
            ) as resp:
                async for chunk in resp.aiter_bytes():
                    yield chunk

    return StreamingResponse(stream_response(), media_type="application/json")
