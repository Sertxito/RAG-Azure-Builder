---
name: 'rag-cost-analyst'
description: 'Comprehensive Azure cost analysis, forecasting, and optimization recommendations. Analyzes infrastructure costs, model inference costs, and identifies savings opportunities.'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





**Status:** Production  
**Version:** 1.0  
**Modules:** `cost_analyzer.py`, `validator.py`

## Purpose

Pre- and post-deployment cost analysis and optimization. Validates configuration against budget before deployment, then calculates actual vs expected costs and recommends specific actions to reduce monthly spend without sacrificing reliability.

## When to Use

- After deployment to validate costs match budget
- Monthly cost reviews
- When identifying cost optimization opportunities
- Before scaling to production

## Cost Components Analyzed

> ⚠️  All prices are estimates in USD. Verify at https://azure.microsoft.com/en-us/pricing/calculator/

### 1. Azure OpenAI — Pay-Per-Token (no monthly fixed fee)

| Model | Input ($/1M tokens) | Output ($/1M tokens) | Use |
|---|---|---|---|
| **gpt-4o** | $2.50 | $10.00 | Minimum quality bar for RAG |
| **o3-mini** | $1.10 | $4.40 | Reasoning-heavy tasks |
| **text-embedding-3-small** | $0.02 | — | Default embeddings |
| **text-embedding-3-large** | $0.13 | — | High-precision embeddings |

> ❌ `gpt-4o-mini` is **not** supported (below quality threshold for RAG)
> Model availability varies by region — see `cost_analyzer.check_model_availability()`.

### 2. Azure AI Search (per replica per month)

| Tier | Cost/replica | Storage | Semantic search |
|---|---|---|---|
| **Free** | $0 | ≤50 MB | ❌ |
| **Basic** | $82 | ≤2 GB | ❌ |
| **Standard S1** | $295 | ≤25 GB | ✅ |
| **Standard S2** | $590 | ≤100 GB | ✅ |

Semantic search add-on: **1,000 free queries/month**, then **$5 per 1,000 queries**.

### 3. Application Insights

- **5 GB/month free**
- Then **$2.30/GB** ingestion
- Typical RAG usage: <1 GB/month → effectively $0

### 4. Storage (Blob, for documents)
- ~**$0.018/GB/month** (Hot tier, LRS)

## Typical Costs (real numbers)

### Scenario A: PoC / Internal tool (1,000 queries/month, 5 GB docs)
```
OpenAI (gpt-4o):           ~$10/mo  (2K input + 500 output tokens/query)
Embeddings (one-off):      ~$1     (one-time, on indexing)
Search Standard S1 x1:     $295/mo
Semantic search:           $0      (under 1K free queries)
App Insights:              $0      (under 5GB free)
Storage (5GB):             $0.09/mo
─────────────────────────────────
TOTAL:                     ~$305/mo
```

### Scenario B: Production (100,000 queries/month, 25 GB docs)
```
OpenAI (gpt-4o):           ~$1,000/mo  (100K × $0.01/query avg)
Embeddings (incremental):  ~$5/mo
Search Standard S1 x2 HA:  $590/mo
Semantic search:           $495/mo     ((100K-1K)/1K × $5)
App Insights:              ~$10/mo
Storage (25GB):            $0.45/mo
─────────────────────────────────
TOTAL:                     ~$2,100/mo
```

## Modules

- **`cost_analyzer.py`** — core: model availability per region (live + static), per-token pricing, budget validation
- **`azure_cost_analyst.py`** — analysis: optimization recommendations, forecasts, cost scoring
- **`validator.py`** — public entry point wrapper

## Usage

```python
from cost_analyzer import validate_deployment

result = validate_deployment(
    doc_size_str="medium",
    budget_usd=2000,
    region="eastus",                  # Region-checked for model availability
    ha_required_str="standard",
    semantic_search=True,
    estimated_docs_gb=5.0,
    estimated_queries_monthly=1000,
    openai_model="gpt-4o",
)

# result includes: region_check, cost_estimate, budget_check, warnings, recommendations
```

## Optimization Levers

| Action | Effort | Savings | Risk |
|---|---|---|---|
| Drop to Standard S1 from S2 (if docs <25GB) | 5 min | $295/mo per replica | Low |
| Disable semantic search (lose ~30% precision) | 5 min | $5/1K queries | Medium (quality) |
| Remove 2nd replica (lose HA) | 5 min | $295/mo | High (no failover) |
| Cache frequent queries (app-side) | 1 hour | 20-40% on OpenAI | Low |
| Use `text-embedding-3-small` over `large` | 5 min | $0.11/1M tokens | Low (quality similar) |

---

**Pro Tip:** Run `cost_analyzer.py` BEFORE deploying to validate budget AND region model availability in one pass.

