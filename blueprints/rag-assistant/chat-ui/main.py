"""RAG Assistant Chat UI — a lightweight FastAPI app that proxies chat
messages to a DigitalOcean managed GenAI agent and serves a simple web
interface.

Environment variables (injected by terraform via App Platform):
    AGENT_UUID      — UUID of the managed agent
    AGENT_API_KEY   — Secret key for authenticating with the agent
    AGENT_ENDPOINT  — Full URL of the agent's OpenAI-compatible chat endpoint
    AGENT_NAME      — Display name of the agent (optional)
"""

import os
from pathlib import Path

import httpx
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse

app = FastAPI(title="RAG Assistant")

AGENT_UUID = os.environ["AGENT_UUID"]
AGENT_API_KEY = os.environ["AGENT_API_KEY"]
AGENT_ENDPOINT = os.environ["AGENT_ENDPOINT"]
AGENT_NAME = os.environ.get("AGENT_NAME", "RAG Assistant")

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
    """Proxy a chat message to the managed agent and return the response."""
    body = await request.json()
    message = body.get("message", "")
    history = body.get("history", [])

    # Build OpenAI-compatible messages array.
    messages = []
    for h in history:
        messages.append({"role": h.get("role", "user"), "content": h.get("content", "")})
    messages.append({"role": "user", "content": message})

    payload = {
        "messages": messages,
    }

    headers = {
        "Authorization": f"Bearer {AGENT_API_KEY}",
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(AGENT_ENDPOINT, json=payload, headers=headers)

    try:
        data = resp.json()
    except Exception:
        return JSONResponse(
            status_code=resp.status_code,
            content={"error": resp.text},
        )

    # Extract the response text from OpenAI-compatible format.
    content = ""
    if "choices" in data and len(data["choices"]) > 0:
        content = data["choices"][0].get("message", {}).get("content", "")

    return JSONResponse(content={
        "content": content,
        "usage": data.get("usage"),
    })
