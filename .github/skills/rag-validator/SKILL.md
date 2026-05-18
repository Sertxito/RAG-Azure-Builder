---
name: 'rag-validator'
description: 'RAG expert validator: checks that agents, instructions, skills and RAG implementation comply with Microsoft RAG best practices and repo guidelines.'
applyTo: '**/*.agent.md, **/*.instructions.md, **/SKILL.md, **/*.py'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)

**Status:** Production  
**Version:** 2.0  
**Last Updated:** May 13, 2026

---

## Purpose

Automated compliance check to ensure this repository remains aligned with Microsoft RAG best practices and agent/skill customization conventions.

This skill validates two layers:

**Layer 1 — Repository structure hygiene:**
- Agent/instruction/skill naming and frontmatter
- Required documentation files
- Catalog purity (`.github/agents` contains only `.agent.md`)

**Layer 2 — RAG quality compliance (aligned with Microsoft Learn):**
- Hybrid search implementation (keyword + semantic/vector)
- Semantic ranking configuration
- Chunking strategy for token constraint management
- Vectorization pipeline
- Result limit (top-k) to prevent LLM token overflow
- Index schema completeness (key, content, vector, semantic config)
- Coverage of the 5 RAG challenges in `rag-best-practices.md`

---

## RAG Compliance Dimensions

Based on [Microsoft's RAG guidance](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos), this validator checks each of the 5 RAG challenge dimensions:

| Challenge | Microsoft Recommendation | Validator Check |
|---|---|---|
| **Query understanding** | Hybrid queries (keyword + vector) + semantic ranking | `hybrid_search`, `semantic_ranking` |
| **Token constraints** | Chunking at index time, top-k limits at query time | `chunking_strategy`, `token_limits` |
| **Multi-source data** | Indexers from Azure Blob, SharePoint, databases | `rag_best_practices_content` |
| **Response time** | Single-shot queries (classic) or parallel subqueries (agentic) | `index_schema` |
| **Security & governance** | Document-level security trimming, Entra ID filters | `rag_best_practices_content` |

### Agentic Retrieval vs Classic RAG

| Use agentic retrieval when… | Use classic RAG when… |
|---|---|
| Client is an agent or chatbot | GA-only features required |
| Highest relevance and accuracy needed | Simplicity and speed are priorities |
| Queries are complex or conversational | Existing orchestration code to preserve |
| Structured responses with citations needed | Fine-grained pipeline control needed |
| Building new RAG implementations | |

References:
- [Agentic retrieval overview](https://learn.microsoft.com/en-us/azure/search/agentic-retrieval-overview)
- [Classic RAG sample](https://github.com/Azure-Samples/azure-search-classic-rag)
- [Hybrid search](https://learn.microsoft.com/en-us/azure/search/hybrid-search-overview)
- [Semantic ranking](https://learn.microsoft.com/en-us/azure/search/semantic-ranking)
- [Security trimming](https://learn.microsoft.com/en-us/azure/search/search-security-built-in)
- [Agentic knowledge sources](https://learn.microsoft.com/en-us/azure/search/agentic-knowledge-source-overview)

---

## When to use

- Before merging changes to `.github/agents`, `.github/instructions`, `.github/skills`
- Before cloning this baseline into a new project
- After modifying indexing or query scripts, to verify RAG quality patterns
- During QA/review to prevent structural drift

Do not use this skill as a runtime health check for Azure resources.

---

## Usage

```bash
# Standard validation
python .github/skills/microsoft-guidelines-validator/guidelines_validator.py --root .

# JSON output (for CI integration)
python .github/skills/microsoft-guidelines-validator/guidelines_validator.py --root . --json

# Strict mode: warnings become failures
python .github/skills/microsoft-guidelines-validator/guidelines_validator.py --root . --strict
```

---

## Checks Performed

### Layer 1: Repository Structure

1. **required_files** — `.github/README.md`, `AGENTS.md`, `ARCHITECTURE.md`, `rag-best-practices.md`, template files
2. **agents_folder** — `.github/agents` contains only `*.agent.md` files
3. **agent_frontmatter** — Required fields: `name`, `description`, `model`, `tools`, `skills`
4. **instruction_pairing** — Each `rag-*.agent.md` has a matching `agent-rag-*.instructions.md`
5. **skill_frontmatter** — `SKILL.md` files contain at least `name` and `description`
6. **microsoft_references** — Key docs include valid `https://learn.microsoft.com/...` links
7. **rag_reference_coverage** — All agents/instructions/skills link to the official RAG overview
8. **naming_conventions** — Agents follow `rag-*.agent.md`, instructions follow `agent-rag-*.instructions.md`

### Layer 2: RAG Quality (Microsoft Best Practices)

9. **hybrid_search** — Query scripts use `search_text` + `query_type="semantic"` or `vector_queries` — Microsoft guidance: [hybrid search](https://learn.microsoft.com/en-us/azure/search/hybrid-search-overview)
10. **semantic_ranking** — `SemanticConfiguration` defined in index schema and activated at query time — Microsoft guidance: [semantic ranking](https://learn.microsoft.com/en-us/azure/search/semantic-ranking)
11. **chunking_strategy** — Indexing scripts split large documents into chunks — addresses Microsoft's token constraint challenge
12. **vectorization** — Pipeline generates vector embeddings required for similarity search
13. **token_limits** — Query scripts configure `top=` or `top_k` limits to prevent LLM token overflow
14. **index_schema** — Index definition includes key field, searchable content field, vector field, and semantic configuration
15. **rag_best_practices_content** — `rag-best-practices.md` covers all 5 Microsoft RAG challenges (query understanding, tokens, multi-source, security, response time)

---

## Output

Example JSON output:

```json
{
  "summary": {
    "passed": 14,
    "warnings": 1,
    "failed": 0,
    "compliant": true
  },
  "checks": [
    {
      "name": "hybrid_search",
      "status": "pass",
      "details": "Query scripts implement hybrid search (keyword + semantic/vector)"
    },
    {
      "name": "semantic_ranking",
      "status": "pass",
      "details": "Semantic ranking configured in both index schema and query layer"
    },
    {
      "name": "chunking_strategy",
      "status": "pass",
      "details": "Chunking patterns detected (chunk, chunk_size, overlap) — aligns with Microsoft content preparation guidance"
    },
    {
      "name": "token_limits",
      "status": "pass",
      "details": "Result limits (top-k) configured — prevents LLM token overflow"
    },
    {
      "name": "rag_best_practices_content",
      "status": "warn",
      "details": "rag-best-practices.md may not address RAG challenges: [response_time]"
    }
  ]
}
```

Exit codes:
- `0` — compliant (no failures; `--strict` also requires no warnings)
- `1` — one or more failing checks

---

## Integration Pattern

Use as a preflight gate in onboarding and review pipelines:

```bash
python .github/skills/microsoft-guidelines-validator/guidelines_validator.py --root . --strict
```

If this command fails, fix the reported issues before continuing with deployment or cloning.

