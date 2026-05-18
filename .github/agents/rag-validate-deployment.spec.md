# SPEC: RAG Validate Deployment

**GitHub Spec Kit Enterprise Compliance**

---

## 1. Overview

| Attribute | Value |
|-----------|-------|
| **Name** | rag-validate-deployment |
| **Purpose** | Validate cost, region availability, and architecture before deploying |
| **Type** | Pre-deployment Validation Skill |
| **Tier** | 1 (Critical — prevents expensive mistakes) |
| **Input** | Configuration (region, model, tier, budget) |
| **Output** | JSON with validation results, recommendations, cost breakdown |
| **Responsibility** | Cost calculation, region validation, quota checking, architecture review |

---

## 2. Input/Output Contract

### 2.1 Input Schema

```json
{
  "action": "validate|compare|recommend",
  "region": "eastus",
  "models": ["gpt-4o", "text-embedding-3-small"],
  "search_sku": "standard",
  "search_replicas": 1,
  "logs_retention_days": 90,
  "documents_count": 5000,
  "estimated_queries_monthly": 1000,
  "budget_usd": 2000,
  "subscription_id": "8e6ace56-e0f2-4071-825a-a20363df34f8"
}
```

**Required Fields:**
- `action`: One of {validate, compare, recommend}
- `region`: Azure region
- `models`: List of models to validate

**Optional Fields:**
- `search_sku`: Default standard
- `documents_count`: Default 5000
- `estimated_queries_monthly`: Default 1000
- `budget_usd`: Default 2000

### 2.2 Output Schema

```json
{
  "timestamp": "2026-05-15T14:30:00Z",
  "action": "validate",
  "status": "success|warning|error",
  "duration_seconds": 5,
  "result": {
    "region": "eastus",
    "validation": {
      "region_valid": true,
      "models_available": {
        "gpt-4o": true,
        "text-embedding-3-small": true
      },
      "quota_sufficient": true,
      "budget_ok": false,
      "architecture_optimized": true
    },
    "cost_breakdown": {
      "monthly_infrastructure": {
        "openai_s0": 10,
        "search_standard_1replica": 295,
        "appinsights_90day": 50,
        "total": 355
      },
      "monthly_inference_estimate": {
        "queries": 1000,
        "avg_cost_per_query": 0.025,
        "total": 25
      },
      "monthly_total_usd": 380,
      "currency": "USD",
      "confidence_pct": 85
    },
    "recommendations": [
      {
        "issue": "Budget exceeded",
        "current": "$380/mo vs $2000 budget",
        "recommendation": "Within budget, good margin for scaling",
        "action": "PROCEED"
      },
      {
        "issue": "Region availability",
        "current": "eastus has all models",
        "recommendation": "Region optimal for gpt-4o",
        "action": "PROCEED"
      },
      {
        "issue": "Search tier right-sizing",
        "current": "Standard 1 replica for 5K docs",
        "recommendation": "Good fit, can scale replicas if QPS > 50/sec",
        "action": "PROCEED"
      }
    ],
    "alternative_regions": [
      {
        "region": "westus2",
        "models_available": ["gpt-4o", "text-embedding-3-small"],
        "monthly_cost_usd": 385,
        "latency_ms": 15
      },
      {
        "region": "swedencentral",
        "models_available": ["gpt-4o"],
        "monthly_cost_usd": 360,
        "latency_ms": 80
      }
    ],
    "quota_check": {
      "subscription": "8e6ace56-e0f2-4071-825a-a20363df34f8",
      "quota_available": {
        "openai_s0_tpm": 200,
        "search_replicas": 3,
        "appinsights_retention": "730 days"
      },
      "quota_sufficient": true
    }
  },
  "error": null,
  "metadata": {
    "pricing_date": "2026-05-15",
    "pricing_source": "azure.microsoft.com/pricing",
    "validation_method": "Cost Management API + Resource Graph"
  }
}
```

---

## 3. Success Criteria

### 3.1 Functional Requirements

| Requirement | Success Metric | Validation |
|---|---|---|
| **Region validation** | Check all 3 services available | Query SKU availability API |
| **Model availability** | Verify models exist in region | List all models per region |
| **Cost accuracy** | ± 5% of actual Azure pricing | Compare vs Cost Management API |
| **Quota checking** | Detect insufficient quotas | Query subscription quotas |
| **Budget comparison** | Show estimated vs budget | Highlight if over budget |
| **Recommendations** | Suggest improvements | Tier comparison, region alternatives |
| **No side effects** | Validation never deploys resources | Zero Azure changes |
| **JSON output** | Valid, parseable schema | Schema validation passes |

### 3.2 Non-Functional Requirements

| Requirement | Target | Measurement |
|---|---|---|
| **Response time** | < 5 seconds | Timer in logs |
| **API calls** | Minimize Azure API calls | Log call count |
| **Caching** | Use cached pricing data | Check if rates are fresh |

---

## 4. Error Handling Table

| Error Code | Condition | Recovery | Retry? |
|---|---|---|---|
| `REGION_NOT_SUPPORTED` | Region doesn't have required model | Suggest alternative regions | No |
| `MODEL_NOT_AVAILABLE` | Specific model not in region | Suggest alternative models | No |
| `QUOTA_INSUFFICIENT` | Subscription quota too low | Suggest requesting increase | No |
| `BUDGET_EXCEEDED` | Configuration over budget | Suggest downgrade options | No |
| `PRICING_API_ERROR` | Can't fetch current pricing | Use cached/estimated rates | Yes |
| `QUOTA_API_ERROR` | Can't check quotas | Continue with warning | Yes |
| `INVALID_CONFIG` | Invalid SKU/tier combination | Suggest valid combinations | No |

---

## 5. Integration Points

### Called By
- **rag-onboarding.agent.md** — Phase 4-5 (before deployment)
- **Manual pre-flight checks** — User validation before deploying

### Calls
- **Azure Pricing API** (cost data)
- **Azure Resource Graph** (SKU availability)
- **Azure Quotas API** (subscription limits)

### Output Consumed By
- **rag-onboarding.agent.md** — Displays cost summary to user
- **Decision gates** — User decides whether to proceed

---

## 6. Release Gates

- [ ] **Region validation** — Correct models per region
- [ ] **Cost accuracy** — ± 5% vs actual pricing
- [ ] **Quota detection** — Catches insufficient quotas
- [ ] **No side effects** — Validation makes zero changes
- [ ] **Alternative suggestions** — Shows regions/configs that fit budget
- [ ] **Error handling** — Invalid input produces helpful errors
- [ ] **Response time** — < 5 seconds
- [ ] **Pricing freshness** — Uses current or recently cached rates

---

## 7. Testing Strategy

```bash
# Test 1: Valid configuration
python validator.py --action validate \
  --region eastus \
  --models gpt-4o text-embedding-3-small \
  --search-sku standard \
  --budget 2000

# Test 2: Over budget
python validator.py --action validate \
  --region eastus \
  --models gpt-4o \
  --search-sku premium \
  --budget 500

# Test 3: Region with limited availability
python validator.py --action validate \
  --region brazilsouth \
  --models gpt-4o

# Test 4: Compare configurations
python validator.py --action compare \
  --region eastus \
  --budget 2000

# Test 5: Get recommendations
python validator.py --action recommend \
  --documents-count 50000 \
  --estimated-queries 10000
```

---

## 8. Pricing Assumptions

**Current Rates (USD)** — Update quarterly:

```
Azure OpenAI:
  • gpt-4o: $2.50/1M input + $10/1M output
  • text-embedding-3-small: $0.02/1M tokens

Azure AI Search:
  • Basic: $75/mo (1M docs max)
  • Standard: $295/mo per replica
  • Premium: $1,500/mo per replica

Application Insights:
  • Free: 5GB/day, 90-day retention
  • Paid: $2.50/GB ingested
```

---

## 9. Version & Changelog

| Version | Date | Changes |
|---|---|---|
| 1.0.0 | 2026-05-15 | Initial Spec Kit release |

---

**Status:** ENTERPRISE READY — Spec Kit Compliant
**Last Updated:** 2026-05-15
