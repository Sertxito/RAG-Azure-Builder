# RAG API Server — REST Interface

**Expose RAG as REST API for external applications.**

## Overview

REST API server wrapping RAG query functionality, allowing HTTP clients to search and query documents.

## Features

- ✅ REST API endpoints
- ✅ JSON request/response
- ✅ Async query processing
- ✅ Metrics and monitoring
- ✅ CORS support

## Requirements

```bash
pip install -r .github/requirements.txt
```

- `.env` with Azure credentials:
  - `AZURE_OPENAI_KEY`
  - `AZURE_OPENAI_ENDPOINT`
  - `AZURE_SEARCH_ENDPOINT`
  - `AZURE_SEARCH_KEY`
  - `AZURE_SEARCH_INDEX`

## Usage

### Start Server

```bash
# From project root
python .github/skills/rag-api-server/servidor-api.py
```

### Default Port

Server runs on `http://localhost:8000`

### API Endpoints

#### POST `/query` — Execute RAG Query

**Request:**
```json
{
  "query": "What is the user onboarding process?",
  "top_k": 5
}
```

**Response:**
```json
{
  "query": "What is the user onboarding process?",
  "response": "Based on the documentation...",
  "sources": [
    "knowledge/pdfs/Onboarding.pdf",
    "knowledge/procedimientos/UserSetup.docx"
  ],
  "metrics": {
    "search_time_ms": 234,
    "inference_time_ms": 1523,
    "total_time_ms": 1757,
    "tokens_used": 412
  }
}
```

#### GET `/health` — Health Check

**Response:**
```json
{
  "status": "healthy",
  "search_endpoint": "https://my-search.search.windows.net",
  "openai_model": "gpt-4o"
}
```

## Example Clients

### cURL

```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"query": "user onboarding", "top_k": 5}'
```

### Python

```python
import requests

response = requests.post(
    "http://localhost:8000/query",
    json={"query": "user onboarding", "top_k": 5}
)

result = response.json()
print(result['response'])
```

### JavaScript

```javascript
fetch('http://localhost:8000/query', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ 
    query: 'user onboarding',
    top_k: 5 
  })
})
.then(r => r.json())
.then(data => console.log(data.response))
```

## Deployment

### Local Development

```bash
python .github/skills/rag-api-server/servidor-api.py
```

### Production (with Gunicorn)

```bash
pip install gunicorn
gunicorn --workers 4 --bind 0.0.0.0:8000 servidor-api:app
```

### Docker

```dockerfile
FROM python:3.10
WORKDIR /app
COPY .github/requirements.txt .
RUN pip install -r requirements.txt
COPY .github/skills/rag-api-server ./server
COPY .env .
EXPOSE 8000
CMD ["python", "server/servidor-api.py"]
```

## Configuration

Via environment variables:

```bash
export API_PORT=8000
export API_HOST=0.0.0.0
python .github/skills/rag-api-server/servidor-api.py
```

## Related Skills

- [`rag-query-cli`](../rag-query-cli/SKILL.md) — CLI alternative
- [`rag-indexer`](../rag-indexer/SKILL.md) — Document indexing
- [`rag-diagnostics`](../rag-diagnostics/SKILL.md) — System monitoring

## See Also

- [.github/README.md](../../README.md) — Architecture
