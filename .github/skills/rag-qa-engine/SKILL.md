---
name: 'rag-qa-engine'
description: 'Interactive conversational RAG query engine for document Q&A'
applyTo: '**/*.agent.md'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





**Status:** Production  
**Version:** 1.0  
**Last Updated:** May 13, 2026

---

## Purpose

Provides interactive conversational interface for querying documents via RAG. Users ask questions in natural language and receive answers from their indexed knowledge base with source attribution.

This skill:
- âœ… **Interactive Loop**: Chat-like interface for multi-turn conversations
- âœ… **Source Attribution**: Shows document sources and confidence scores
- âœ… **Token Tracking**: Monitors OpenAI token usage per query
- âœ… **Error Handling**: Graceful handling of Azure service issues
- âœ… **UTF-8 Support**: Cross-platform chat (Windows, Linux, Mac)
- âœ… **Extensible**: Easy to inject real Azure OpenAI/Search APIs

---

## Use Cases

### When to use this skill

- **Document Q&A**: Users asking questions about indexed documentation
- **Interactive Validation**: PoC/validation of RAG capabilities
- **Knowledge Base Chat**: Company wiki, procedure manuals, runbooks
- **Multi-turn Conversations**: Follow-up questions, context preservation
- **Integration**: API wrapper for web/mobile chat interfaces

### When NOT to use

- Batch/non-interactive queries (use REST API)
- Real-time streaming responses (different implementation)
- Non-text queries (images, audio)

---

## Python Usage

### As a Callable Module

```python
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent / ".github" / "skills" / "rag-qa-engine"))

from chat_engine import RAGChatEngine



engine = RAGChatEngine(
    azure_openai_endpoint="https://myapp-openai.openai.azure.com/",
    azure_search_endpoint="https://myapp-search.search.windows.net/"
)



engine.connect()



response = engine.query("What is the procedure for X?")
print(response["answer"])
print(response["sources"])



exit_code = engine.run_interactive()
```

### As a Standalone CLI

```bash
python .github/skills/rag-qa-engine/chat_engine.py



python run-rag.py --agent chat
```

---

## Input

### Constructor Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `azure_openai_endpoint` | str | OpenAI Service endpoint | `https://app-openai.openai.azure.com/` |
| `azure_search_endpoint` | str | AI Search endpoint | `https://app-search.search.windows.net/` |

### Query Method

| Parameter | Type | Description |
|-----------|------|-------------|
| `question` | str | Natural language question |

---

## Output

### Single Query Response

```python
{
    "answer": "str - Generated answer from RAG",
    "sources": [
        {
            "title": "str - Document name",
            "confidence": "float - 0.0-1.0"
        },
        ...
    ],
    "tokens_used": "int - OpenAI tokens consumed"
}
```

### Interactive Mode

Real-time Q&A loop with:
- User prompts: `You: [question]`
- RAG responses with sources
- Token usage tracking
- Exit commands: `quit`, `exit`, `salir`

---

## Architecture

### Query Flow

```
User Input
    â†“
[Question Analysis]
    â†“
[Semantic Search] â†’ Find relevant docs in Azure Search
    â†“
[Context Preparation] â†’ Format top-K docs as context
    â†“
[gpt-4o Call] â†’ Generate answer with context
    â†“
[Source Attribution] â†’ Return sources + confidence
    â†“
Display to User
```

---

## Configuration

### Azure Services Required

1. **Azure OpenAI Service**
   - Model: gpt-4o or gpt-4o
   - API Version: 2024-08-01
   - Deployment name: configured in `.env`

2. **Azure AI Search**
   - Tier: Standard or higher
   - Vector search enabled
   - Semantic ranking enabled
   - Query language: English

### Environment Variables

```bash
AZURE_OPENAI_ENDPOINT=https://[resource]-openai.openai.azure.com/
AZURE_OPENAI_API_KEY=<key>
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o

AZURE_SEARCH_ENDPOINT=https://[resource]-search.search.windows.net/
AZURE_SEARCH_API_KEY=<key>
```

---

## Chat Commands

| Command | Effect |
|---------|--------|
| `quit` | End session |
| `exit` | End session |
| `salir` | End session (Spanish) |
| `Ctrl+C` | Interrupt |
| empty line | Skip, continue prompt |

---

## Response Format

### Success Response

```
You: What are the procedures for X?

RAG: Based on your documentation, the procedures for X include...

Sources:
  â€¢ procedures.docx (confidence: 0.95)
  â€¢ manual_chapter_3.pdf (confidence: 0.87)

Tokens used: 342
```

### Error Response

```
You: [question]

Error: Failed to connect to Azure Search

[Continues prompting]
```

---

## Session Management

### Session Tracking

- Session start timestamp (for audit)
- Query count
- Total tokens used
- Documents accessed

Logged to:
- Console output (real-time)
- `logs/rag-chat.log` (if file logging enabled)

---

## Extensibility

### Add Real Azure Integration

```python



from azure.search.documents import SearchClient
from openai import AzureOpenAI

def query(self, question: str) -> dict:
    # 1. Search for relevant docs
    search_client = SearchClient(...)
    results = search_client.search(question)
    
    # 2. Format context
    context = "\n".join([doc['content'] for doc in results])
    
    # 3. Call OpenAI
    openai_client = AzureOpenAI(...)
    response = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": f"Context: {context}\n\nQuestion: {question}"}]
    )
    
    # 4. Return answer
    return {"answer": response.choices[0].message.content, "sources": [...]}
```

---

## Dependencies

### Required
- Python 3.10+
- UTF-8 encoding support

### Optional (for real integration)
- `azure-search-documents` (Azure Search SDK)
- `openai` (OpenAI Python SDK)

### Fallback
Without real Azure SDK, returns mock responses suitable for validation.

---

## Logs

- **Console**: Real-time chat output
- **File**: `logs/rag-chat.log` (if enabled)

---

## Error Handling

| Error | Handling |
|-------|----------|
| Azure connection failed | Display error, continue prompting |
| Empty question | Skip, re-prompt |
| Timeout | Retry or skip |
| Token limit exceeded | Warn user, suggest shorter questions |

---

## Performance

- **Latency**: ~2-5 seconds per query (Azure API time)
- **Throughput**: Limited by Azure OpenAI quota
- **Concurrency**: Single-user for interactive mode; for multi-user, use REST API wrapper

---

## Related Skills

- [`rag-orchestration`](../rag-orchestration/SKILL.md) - Setup phase for QA engine
- [`rag-deployment-templates`](../rag-deployment-templates/SKILL.md) - Deploys Search/OpenAI endpoints
- [`rag-rag-rag-agent-instrumentation`](../rag-rag-rag-agent-instrumentation/SKILL.md) - Query metrics and observability

---

## For Next Project

Copy `rag-qa-engine/` skill folder to next project's `.github/skills/` and:

1. Update `.env` with new Azure endpoints
2. Run orchestration to index new knowledge
3. Execute chat engine against new docs

Code is 100% reusable.

---

## Example Session

```
============================================================
RAG Chat Engine - Interactive Query Mode
============================================================

Connected to Azure OpenAI
Connected to Azure Search

Type 'quit' or 'exit' to end session

You: What is MENSADEF?
RAG: MENSADEF is a document management system for...

Sources:
  â€¢ Overview.pdf (confidence: 0.96)
  â€¢ Architecture.docx (confidence: 0.88)

Tokens used: 287

You: How do I send an official document?
RAG: To send an official document in MENSADEF...

Sources:
  â€¢ Procedures.pdf (confidence: 0.94)
  â€¢ User Manual Chapter 5.docx (confidence: 0.82)

Tokens used: 312

You: quit

Goodbye!
```

---

