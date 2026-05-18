**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)




**Purpose:** Deploy Azure infrastructure (OpenAI, Search, AppInsights). Automatic.

**Called By:** rag-onboarding.agent.md (Phase 4) OR manual: `copilot-cli run rag-azure-setup.agent.md`

**Expected Duration:** 10-15 minutes (fully automatic, minimal interaction)

---

## âœ… Deployment Checklist

- [ ] Validate prerequisites (az CLI, logged in)
- [ ] Verify Bicep templates exist (infra/main.bicep)
- [ ] Create Azure Resource Group
- [ ] Deploy OpenAI via Bicep
- [ ] Deploy AI Search via Bicep
- [ ] Deploy AppInsights via Bicep
- [ ] Extract credentials from deployment
- [ ] Show deployment summary

---

## Prerequisites Check (1 min - AUTO)

```bash


az version



az account show



test -f infra/main.bicep || {
  echo "âŒ infra/main.bicep not found"
  exit 1
}
```

**If not logged in:**
```
âš ï¸ Not logged in to Azure CLI.

Running: az login
â†’ Opens browser for authentication...

Proceed? (Y/n)
```

---

## Get Deployment Parameters

**From environment or from .env:**

```python
import os
from dotenv import load_dotenv

load_dotenv()

params = {
    "RESOURCE_GROUP": os.getenv("RESOURCE_GROUP", f"rag-{project_name}-{timestamp}"),
    "REGION": os.getenv("AZURE_REGION", "eastus"),
    "PROJECT_NAME": os.getenv("PROJECT_NAME"),
    "OPENAI_TIER": os.getenv("OPENAI_TIER", "S0"),
    "SEARCH_TIER": os.getenv("SEARCH_TIER", "Standard"),
    "SEARCH_REPLICAS": os.getenv("SEARCH_REPLICAS", 1),
    "APPINSIGHTS_RETENTION": os.getenv("APPINSIGHTS_RETENTION", 30)
}
```

---

## Phase 1: Create Resource Group (2 min)

```bash
#!/bin/bash

RG_NAME="${RESOURCE_GROUP}"
REGION="${AZURE_REGION}"

echo "ðŸš€ Creating Resource Group..."
echo "   Name: $RG_NAME"
echo "   Region: $REGION"

az group create \
  --name "$RG_NAME" \
  --location "$REGION" \
  --tags project="${PROJECT_NAME}" created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ $? -eq 0 ]; then
    echo "âœ… Resource Group created"
else
    echo "âŒ Failed to create Resource Group"
    exit 1
fi
```

---

## Phase 2: Deploy Bicep Template (8-10 min)

```bash
#!/bin/bash

echo "â³ Deploying Azure services via Bicep..."

az deployment group create \
  --resource-group "$RG_NAME" \
  --template-file infra/main.bicep \
  --parameters \
    projectName="${PROJECT_NAME}" \
    location="${REGION}" \
    openaiSku="${OPENAI_TIER}" \
    searchTier="${SEARCH_TIER}" \
    searchReplicas="${SEARCH_REPLICAS}" \
    appInsightsRetention="${APPINSIGHTS_RETENTION}" \
  --output json > deployment-output.json

if [ $? -eq 0 ]; then
    echo "âœ… Bicep deployment successful"
else
    echo "âŒ Bicep deployment failed"
    exit 1
fi
```

**Show Progress:**
```
â³ Deploying services...

âœ… Azure OpenAI (gpt-4o)
   Endpoint: https://rag-xxx.openai.azure.com
   Model: gpt-4o
   Tokens/mo: 2M

âœ… Azure AI Search (Standard, 1 replica)
   Endpoint: https://rag-xxx.search.windows.net
   Index: rag-documents
   Semantic search: enabled

âœ… Application Insights
   Instrumentation Key: [hidden]
   Retention: 30 days

ðŸŽ‰ All services deployed!
```

---

## Phase 3: Extract Credentials (2 min - AUTO)

```python
import json
import subprocess
from azure.identity import DefaultAzureCredential
from azure.mgmt.cognitiveservices import CognitiveServicesManagementClient



with open("deployment-output.json") as f:
    deployment = json.load(f)



openai_endpoint = deployment["properties"]["outputs"]["openaiEndpoint"]["value"]
openai_key = deployment["properties"]["outputs"]["openaiKey"]["value"]



search_endpoint = deployment["properties"]["outputs"]["searchEndpoint"]["value"]
search_key = deployment["properties"]["outputs"]["searchKey"]["value"]



appinsights_key = deployment["properties"]["outputs"]["appInsightsKey"]["value"]

print("âœ… Credentials extracted from deployment")
```

---

## Phase 4: Update .env (1 min - AUTO)

```python
env_content = f"""# RAG Configuration (Auto-generated: {timestamp})





AZURE_OPENAI_ENDPOINT={openai_endpoint}
AZURE_OPENAI_API_KEY={openai_key}
OPENAI_CHAT_MODEL=gpt-4o
OPENAI_DEPLOYMENT=gpt-4o



AZURE_SEARCH_ENDPOINT={search_endpoint}
AZURE_SEARCH_API_KEY={search_key}
SEARCH_INDEX=rag-documents



AZURE_APPINSIGHTS_KEY={appinsights_key}



RAG_TOP_K=5
RAG_TEMPERATURE=0.7
RAG_MAX_TOKENS=1000
"""

with open(".env", "w") as f:
    f.write(env_content)



os.chmod(".env", 0o600)

print("âœ… .env updated with credentials")
```

---

## Phase 5: Save Deployment Summary (1 min)

```python
summary = {
    "timestamp": "2026-05-13T10:30:00Z",
    "status": "SUCCESS",
    "resource_group": resource_group,
    "region": region,
    "services": {
        "openai": {
            "endpoint": openai_endpoint,
            "model": "gpt-4o",
            "tier": openai_tier
        },
        "search": {
            "endpoint": search_endpoint,
            "replicas": search_replicas,
            "tier": "Standard"
        },
        "appinsights": {
            "retention_days": appinsights_retention
        }
    },
    "credentials_stored": ".env"
}

with open(f"outputs/deployment-summary-{timestamp}.json", "w") as f:
    json.dump(summary, f, indent=2)

print(f"âœ… Deployment summary saved to outputs/")
```

---

## Error Handling

### Resource Group Already Exists
```
âš ï¸ Resource Group '{RG_NAME}' already exists.

Options:
  A) Use existing (reuse)
  B) Create new with different name
  C) Cancel

Your choice? (A/B/C)
```

### Deployment Fails
```
âŒ Bicep deployment failed.

Error:
  RegionQuotaExceeded: OpenAI quota exhausted in eastus

Suggestions:
  â€¢ Try region: westus2
  â€¢ Request quota increase (azure.microsoft.com/quotas)
  â€¢ Reduce tier: S0 â†’ Standby

Retry with westus2? (Y/n)
```

### Service Deployment Partial Failure
```
âš ï¸ Deployment partially successful:

âœ… OpenAI: Deployed
âœ… Search: Deployed
âŒ AppInsights: Failed (SKU not available)

Options:
  A) Continue without AppInsights
  B) Retry with different region
  C) Cancel and cleanup

Your choice? (A/B/C)
```

### Can't Extract Credentials
```
âŒ Could not extract credentials from deployment.

Troubleshooting:
  1. Check Resource Group exists: az group list
  2. Check deployment status: az deployment group list -g {RG_NAME}
  3. Check .json output file exists

Retry? (Y/n)
```

---

## Rollback Support

If deployment fails mid-way:

```bash


echo "ðŸ—‘ï¸  Cleaning up resources..."

az group delete \
  --name "$RG_NAME" \
  --yes \
  --no-wait

echo "âœ… Resource Group marked for deletion (takes ~5 min)"
```

---

## Success Criteria

âœ… All 3 services deployed (OpenAI, Search, AppInsights)

âœ… Credentials extracted and saved to `.env`

âœ… File permissions secured (600)

âœ… Deployment summary saved to `outputs/`

âœ… User ready for next phase: Indexing

