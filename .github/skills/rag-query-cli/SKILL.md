# RAG Query CLI — Interactive Document Search

**Query your RAG system interactively from the command line.**

## Overview

Interactive CLI for searching and querying documents indexed in your RAG system using Azure AI Search + Azure OpenAI.

## Features

- ✅ Hybrid search (keyword + semantic ranking)
- ✅ Document retrieval with source tracking
- ✅ Response generation with context
- ✅ Performance metrics
- ✅ Handles UTF-8 special characters (Windows compatible)

## Requirements

- Azure OpenAI account with deployed model
- Azure AI Search instance with indexed documents
- `.env` file with credentials:
  - `AZURE_OPENAI_KEY`
  - `AZURE_OPENAI_ENDPOINT`
  - `AZURE_SEARCH_ENDPOINT`
  - `AZURE_SEARCH_KEY`
  - `AZURE_SEARCH_INDEX`
  - `AZURE_OPENAI_MODEL`

## Installation

```bash
# Dependencies are in ../.../requirements.txt
pip install -r .github/requirements.txt
```

## Usage

### Interactive Query (Recommended)

```bash
# From project root
python .github/skills/rag-query-cli/consultar.py "Your question here"

# Example
python .github/skills/rag-query-cli/consultar.py "What is the user onboarding process?"
```

### Direct Execution

```python
from consultar import RAGExecutor

executor = RAGExecutor()
result = executor.execute("your question", verbose=True)

print(result['response'])
print("Sources:", result['sources'])
print("Metrics:", result['metrics'])
```

## Output

```
[QUERY] What is the user onboarding process?

[SEARCHING] Searching documents...
[OK] Found 5 relevant documents

[GENERATING] Generating response...
[OK] Response generated

[RESPONSE]
Based on the documentation, the user onboarding process involves...

[SOURCES]
   - knowledge/pdfs/Onboarding_Manual.pdf
   - knowledge/procedimientos/User_Setup.docx

[METRICS]
   Search: 234ms
   Inference: 1523ms
   Total: 1757ms
   Tokens: 412
```

## Advanced Options

### Custom Top-K Results

```bash
# Retrieve more context (default is 5)
python .github/skills/rag-query-cli/consultar.py "question" --top 10
```

### Quiet Mode

```bash
# Only output the response
python .github/skills/rag-query-cli/consultar.py "question" --quiet
```

## Search Modes

- **Hybrid (Default)**: Keyword search with BM25 + Semantic ranking (best for most queries)
- **Keyword**: Fast, good for exact matches
- **Semantic**: Better understanding of meaning, slower

## Troubleshooting

| Issue | Solution |
|---|---|
| `Missing AZURE_OPENAI_KEY` | Fill in `.env` with your credentials |
| `No relevant documents found` | Index documents first with `rag-indexer` skill |
| `Semantic ranking not available` | Falls back to keyword search automatically |
| Unicode errors on Windows | Script auto-fixes UTF-8 encoding |

## Performance Notes

- First query may take 2-3 seconds (model warm-up)
- Subsequent queries: 500ms - 2 seconds
- Inference time depends on model (GPT-5 faster than Claude)

## Related Skills

- [`rag-indexer`](../rag-indexer/SKILL.md) — Index documents
- [`rag-diagnostics`](../rag-diagnostics/SKILL.md) — Check system health
- [`rag-api-server`](../rag-api-server/SKILL.md) — REST API wrapper

## See Also

- [.github/README.md](../../README.md) — Main architecture
- [.github/STANDALONE_GUIDE.md](../../STANDALONE_GUIDE.md) — Project setup
