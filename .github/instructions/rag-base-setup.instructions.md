**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)




Standards for rag-builder setup: clear onboarding, cost awareness, observability consistency.

## Quick Checklist

- [ ] Python 3.10+ installed
- [ ] `.env` configured with Azure credentials
- [ ] Azure CLI logged in (`az login`)
- [ ] Pre-deployment validator run (check costs)
- [ ] Azure infrastructure deployed
- [ ] Documents indexed in AI Search
- [ ] RAG query test successful

## Key Standards

### 1. Cost Awareness First

Always run cost validator BEFORE deploying:
```bash
copilot-cli run .github/agents/rag-validate-deployment.agent.md
```

This prevents $1K+ monthly surprises from:
- Over-provisioned Search tier
- Excessive AppInsights retention
- Wrong OpenAI model tier

### 2. Logging & Observability

All operations must log to:
- `./logs/rag.log` (local)
- Azure Application Insights (remote)

Capture:
- Query input + response
- Search latency + document count
- Inference latency + tokens
- Cost per operation

### 3. Error Handling

Every agent/script must:
- Try setup steps with clear error messages
- Suggest remediation ("Region quota full? Try westus2")
- Never silently fail
- Log all failures

### 4. Environment Folder Organization

**Users must organize docs BEFORE running wizard:**

```
knowledge/
â”œâ”€â”€ pdfs/               # PDFs (manuales, polÃ­ticas, guÃ­as, especificaciones)
â”œâ”€â”€ procedimientos/     # Word (.docx), Excel (.xlsx), Markdown (.md) procedural docs
â”œâ”€â”€ codigo/             # SQL, Python, JavaScript, configuration files (YAML, JSON)
â””â”€â”€ presentaciones/     # PowerPoint (.pptx), diagramas, architecture docs
```

**Agent Responsibility:** 
- rag-onboarding.agent.md MUST check `knowledge/` folder exists with all 4 subdirs
- If missing, CREATE them + GUIDE user to populate
- If empty, WARN but continue (can be added later)

### 5. Wizard Automation Flow (FULLY AUTOMATIC)

**rag-onboarding.agent.md MUST execute these phases with ZERO user intervention:**

#### Phase 1: Interview User (5 min)
```
Ask ONLY these 5 questions (no more):
1. Project name? (e.g., "rag-builder")
2. Project description? (1-2 sentences)
3. Total documentation size? (small: <1GB, medium: 1-10GB, large: >10GB)
4. Monthly Azure budget? (default: $2,000)
5. Preferred Azure region? (default: eastus)
```

#### Phase 2: Recommend Config (1 min - AUTOMATIC)
```
Based on doc size + budget:

IF small (<1GB):
  â”œâ”€ OpenAI: S0 (pay-per-token, ~$10/1K queries avg)
  â”œâ”€ Search: Standard 1 replica ($200)
  â””â”€ AppInsights: 30-day retention ($50)
  â””â”€ TOTAL: $1,450/mo

IF medium (1-10GB):
  â”œâ”€ OpenAI: S0 (pay-per-token, ~$10/1K queries avg)
  â”œâ”€ Search: Standard 2 replicas ($250)
  â””â”€ AppInsights: 30-day retention ($50)
  â””â”€ TOTAL: $1,500/mo

IF large (>10GB):
  â”œâ”€ OpenAI: S1 (4M tokens/mo, $2,400)
  â”œâ”€ Search: Standard 3 replicas ($300)
  â””â”€ AppInsights: 30-day retention ($50)
  â””â”€ TOTAL: $2,750/mo

ALWAYS show recommendation + ask user "OK to proceed?"
```

#### Phase 3: Validate Costs (1 min - AUTOMATIC)
```
Check:
- User budget >= recommended config
- Region has quota available (az vm list-skus)
- Subscription has quota for OpenAI + Search

IF over budget:
  â””â”€ SUGGEST: "Try smaller config or request Azure quota increase"
  â””â”€ ALLOW OVERRIDE: "Continue anyway? (Y/n)"

IF quota issue:
  â””â”€ SUGGEST: "Try region: westus2" or "Request quota increase"
  â””â”€ BLOCK until resolved
```

#### Phase 4: Deploy Infrastructure (10 min - AUTOMATIC)
```
Deploy using Bicep templates:
1. Create Resource Group
2. Deploy Azure OpenAI
3. Deploy Azure AI Search
4. Deploy Application Insights

Show progress:
  âœ… Resource Group created
  âœ… OpenAI deployed (gpt-4o)
  âœ… Search created (semantic search enabled)
  âœ… AppInsights configured

IF FAILURE:
  â””â”€ Show error message
  â””â”€ Suggest: "Check region quota" or "Try different region"
  â””â”€ ALLOW RETRY with different region
```

#### Phase 5: Index Documents (10-15 min - AUTOMATIC)
```
Scan knowledge/ folder + process ALL files:

FOR EACH subdirectory:
  â”œâ”€ knowledge/pdfs/          â†’ Extract text via OCR â†’ Chunks
  â”œâ”€ knowledge/procedimientos/ â†’ Parse .docx/.xlsx/.md â†’ Chunks
  â”œâ”€ knowledge/codigo/         â†’ Parse SQL/Python/JS â†’ Chunks
  â””â”€ knowledge/presentaciones/ â†’ Extract text from PPT â†’ Chunks

THEN:
  â”œâ”€ Generate embeddings via OpenAI (text-embedding-3-small)
  â”œâ”€ Upload chunks to Azure Search
  â””â”€ Enable semantic search indexing

SHOW PROGRESS:
  âœ… Processed 42 PDFs (1,200 chunks)
  âœ… Processed 15 Word docs (350 chunks)
  âœ… Processed 8 SQL files (400 chunks)
  âœ… Processed 3 PPTs (180 chunks)
  âœ… TOTAL: 2,130 chunks indexed

IF ERRORS:
  â””â”€ Log failed files
  â””â”€ Continue with others (don't block)
  â””â”€ Show: "Indexed 2,100/2,130 chunks. 30 files had errors. Check logs."
```

#### Phase 6: Setup Credentials (1 min - AUTOMATIC)
```
Generate .env file with:
  AZURE_OPENAI_ENDPOINT=...
  AZURE_OPENAI_API_KEY=...
  AZURE_SEARCH_ENDPOINT=...
  AZURE_SEARCH_API_KEY=...
  AZURE_APPINSIGHTS_KEY=...
  SUBSCRIPTION_ID=...
  RESOURCE_GROUP=...

SAVE to: .env (git-ignored)
```

#### Phase 7: Test Connections (2 min - AUTOMATIC)
```
Verify all services working:
  âœ… OpenAI connected (call /models endpoint)
  âœ… Search connected (call /indexes endpoint)
  âœ… AppInsights connected (send test event)

IF ANY FAIL:
  â””â”€ Show error: "OpenAI unreachable: check API key in .env"
  â””â”€ OFFER RETRY
```

#### Phase 8: Ready! (1 min - AUTOMATIC)
```
Display usage instructions:

ðŸ“š Your RAG is ready! Choose your mode:

MODE A: Quick Queries (CLI)
  $ python scripts/consulta/consultar.py "Â¿CuÃ¡l es X?"
  Latency: 2s | Cost: $0.02/query

MODE B: Chat Conversational
  $ copilot-cli run .github/agents/rag-chat.agent.md
  Latency: 5s | Cost: $0.05/turn

MODE C: REST API (For Apps)
  $ python scripts/consulta/servidor-api.py --port 8000
  curl -X POST http://localhost:8000/query
  Latency: 3s | Cost: $0.03/query

ðŸ“– Read QUERY_MODES.md for detailed examples

Save setup summary to: outputs/setup-summary-{timestamp}.json
```

### 6. Error Handling & Resumption

**Every agent phase must:**
- Log step completion to: `outputs/wizard-checkpoint.json`
- IF interrupted â†’ resume from last checkpoint
- Example:
  ```json
  {
    "phase": 4,
    "status": "completed",
    "timestamp": "2026-05-13T10:30:00Z",
    "next": "Phase 5: Index Documents"
  }
  ```

**If user restarts wizard:**
```
Detected incomplete setup.
Continue from Phase 5: Index Documents? (Y/n)
```

### 7. Configuration

All config through `.env`:
- No hardcoded endpoints/keys
- Clear variable names
- Comments explaining each setting
- Validation on startup (`validate_setup.py`)

---

## Typical Error Resolution

### "Invalid OpenAI endpoint"
â†’ Check `AZURE_OPENAI_ENDPOINT` in `.env`
â†’ Run: `az cognitiveservices account show --resource-group rag-builder-rg --name your-openai`

### "Search index not found"
â†’ Index hasn't been created yet
â†’ Run: `copilot-cli run .github/agents/rag-indexer-specialist.agent.md`

### "Quota exceeded for model deployment"
â†’ Region overbooked
â†’ Change `AZURE_REGION` in `.env` to different region (westus2, northeurope)
â†’ Re-run setup agent

### "High search latency"
â†’ Check `AZURE_SEARCH_REPLICAS` (should be 2+ for prod)
â†’ Monitor: `app-insights-query.kql` (see queries below)

---

## Monitoring KQL Queries

Use these in Application Insights to track RAG health:

### Query Latency
```kusto
customMetrics
| where name == "rag_query_latency_ms"
| summarize P50=percentile(value, 50), P95=percentile(value, 95), P99=percentile(value, 99) by bin(timestamp, 5m)
```

### Cost Tracking
```kusto
customMetrics
| where name == "cost_per_query_usd"
| summarize total_cost=sum(value), query_count=count() by tostring(customDimensions.operation)
```

### Index Health
```kusto
customMetrics
| where name == "search_document_count"
| summarize latest=max_by(value, timestamp) by tostring(customDimensions.index_name)
```

---

## Next Steps

1. Copy `.env.example` to `.env`
2. Fill in Azure credentials (see setup agents)
3. Run `python scripts/validate_setup.py --verbose`
4. Follow prompts to deploy
5. Test with: `python scripts/consulta/consultar.py "Test query"`

