---
name: 'rag-deployment-templates'
description: 'Bicep IaC templates for deploying Azure OpenAI, AI Search, and Application Insights. Reusable across any RAG project. Includes main.bicep and deploy.sh orchestration.'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





**Status:** Production  
**Version:** 1.0  
**Bundled assets:** `main.bicep`, `deploy.sh`, `deployer.py`, `indexer_runner.py`, `document_indexer.py`

## Purpose

Infrastructure-as-Code templates and deployment orchestration for complete Azure stack:
- Azure Cognitive Services (OpenAI) with multiple model deployments
- Azure AI Search (Standard tier for vector search)
- Application Insights + Log Analytics
- Document indexing and deployment runners
- All configured, linked, and automated

## Usage

```bash
cd infra/
./deploy.sh \
  --resource-group rag-rg \
  --region eastus
```

## Deployed resources

- `Azure OpenAI Service` (S0 tier, pay-per-token)
  - Deployments: **gpt-4o** (GlobalStandard, capacity 10), **text-embedding-3-small** (Standard, capacity 50)
  - Note: `gpt-4o-mini` is **not** deployed (below quality bar for RAG)
  - Model availability varies by region — verify with `cost_analyzer.check_model_availability()`

- `Azure Search` (Standard S1)
  - Vector + semantic search enabled
  - Index: `rag-documents`
  - Replicas: 1 (no HA by default; add 2nd replica for HA = +$295/mo)

- `Application Insights`
  - Log Analytics Workspace (PerGB2018 tier)
  - 5 GB/month free ingestion

## Outputs

- Connection strings and endpoints
- API keys for all services
- Deployment info → `outputs/deployment_summary.json`

## Cost estimate (real Azure pricing)

> ⚠️ All prices are estimates in USD. Verify at https://azure.microsoft.com/en-us/pricing/calculator/

**Idle / PoC (1K queries/mo, 5 GB docs):**
- OpenAI (pay-per-token): ~$10/mo
- Search Standard S1 (1 replica): $295/mo
- Application Insights: $0 (under 5GB free)
- Storage: ~$0.09/mo
- **Total: ~$305/mo**

**Production (100K queries/mo, 25 GB docs, HA):**
- OpenAI: ~$1,000/mo
- Search Standard S1 (2 replicas): $590/mo
- Semantic search: ~$495/mo (over free tier)
- App Insights: ~$10/mo
- **Total: ~$2,100/mo**

See `rag-cost-analyst/SKILL.md` for full breakdown.

## Cleanup

```bash
az group delete --name rag-rg --yes
```

## Used by

- `rag-azure-setup.agent.md`
- Any Azure infrastructure deployment

