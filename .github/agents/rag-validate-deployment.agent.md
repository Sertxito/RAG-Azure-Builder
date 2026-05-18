---
name: 'RAG: Validate Deployment'
description: 'Validates cost and architecture before deploying RAG infrastructure. Prevents expensive mistakes with cost analysis and tier recommendations.'
model: 'claude-opus-4.7'
tools: true
skills: ['rag-architecture-optimizer', 'rag-cost-analyst', 'rag-validator']
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)

## Purpose

Run **BEFORE** `rag-azure-setup.agent.md` to validate:
- ✅ Cost fits budget
- ✅ Architecture is right-sized
- ✅ Models available in target region
- ✅ No over-provisioning
- ✅ Optimizations recommended

---

## When to use

- `Validate deployment cost`
- `Check if configuration is optimal`
- `Review architecture before deploy`
- `Find cost savings`

---

## Workflow

### 1. Load Configuration

From `.env` or user input:
- `AZURE_REGION` (eastus, westus2, swedencentral…)
- `AZURE_SEARCH_TIER` (basic, standard)
- `AZURE_SEARCH_REPLICAS` (1-12)
- `APP_INSIGHTS_RETENTION_DAYS` (30-730)
- `ESTIMATED_QUERIES_MONTHLY` (default: 1,000)
- `BUDGET_USD` (default: 2,000)

### 2. Check Region → Model Availability

```python
from cost_analyzer import validate_region_models
check = validate_region_models(["gpt-4o", "text-embedding-3-small"], region)
# If not available → suggest swedencentral / eastus / northeurope
```

### 3. Analyze with Azure Architect

✅ **Checks:**
- Search tier appropriate for document volume?
- Replicas right-sized for QPS?
- OpenAI tier sufficient?
- AppInsights retention reasonable?

🔍 **Output:** Architecture recommendations

### 4. Analyze with Cost Analyst

📊 **Calculates:**
- Monthly infrastructure cost
- Estimated monthly inference cost
- Total monthly spend
- Optimizations available

### 5. Present Findings

```
COST BREAKDOWN (Monthly)          ⚠️  Estimates in USD (verify at azure.com/pricing)
─────────────────────────────────────────────────────────────────────
Azure OpenAI (S0, pay-per-token)    ~$10
  • 1K queries × ~$0.010/query (gpt-4o: $2.50/1M in + $10/1M out)
  • Scales directly with query volume

Azure AI Search Standard S1          $295
  • 1 replica (add 2nd for HA: +$295/mo)
  • Semantic: $0 under 1K queries/mo, then $5/1K

App Insights                           $0
  • Under 5 GB/month free

Storage                                $0
  • Under 50 GB

CURRENT TOTAL: ~$305/month  (1K queries, 1 replica, no HA)
WITH HA (2 replicas): ~$600/month

Recommendation: Standard S1 required for vector + semantic search.
Proceed? (yes/no)
```

---

## Next Steps

✅ If approved: Run `rag-azure-setup.agent.md`
❌ If rejected: Adjust config and re-run validator