**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)




**Purpose:** Validate costs and architecture BEFORE deploying. Prevents budget surprises.

**User Entry:** `copilot-cli run .github/agents/rag-validate-deployment.agent.md`

**Expected Duration:** ~2 minutes

---

## What This Agent Does

Validates setup will fit user's budget + Azure constraints BEFORE any deployment happens.

---

## âœ… Validation Checklist

- [ ] Ask user for: doc size, budget, region
- [ ] Look up current Azure quotas in region
- [ ] Calculate infrastructure costs
- [ ] Compare vs budget
- [ ] Show detailed cost breakdown
- [ ] WARN if over-provisioned
- [ ] ALLOW to proceed or adjust

---

## Step-by-Step

### Step 1: Get User Input (1 min)

```
Ask (again if needed):
  1. Documentation size? (small/medium/large)
  2. Monthly budget? (USD, default: $2,000)
  3. Azure region? (default: eastus)
  4. Do you need high availability? (Y/n, default: n)
```

### Step 2: Recommend Tiers (30 sec - AUTO)

```python
configurations = {
    ("small", False): {  # small docs, no HA
        "openai": ("S0", 1200),
        "search": ("Standard 1 replica", 200),
        "appinsights": ("30 days", 50),
        "total": 1450
    },
    ("small", True): {   # small docs, HA
        "openai": ("S0", 1200),
        "search": ("Standard 2 replicas", 250),
        "appinsights": ("90 days", 100),
        "total": 1550
    },
    ("medium", False): {
        "openai": ("S0", 1200),
        "search": ("Standard 2 replicas", 250),
        "appinsights": ("30 days", 50),
        "total": 1500
    },
    ("medium", True): {
        "openai": ("S0", 1200),
        "search": ("Standard 3 replicas", 300),
        "appinsights": ("90 days", 100),
        "total": 1600
    },
    ("large", False): {
        "openai": ("S1", 2400),
        "search": ("Standard 3 replicas", 300),
        "appinsights": ("30 days", 50),
        "total": 2750
    },
    ("large", True): {
        "openai": ("S1", 2400),
        "search": ("Standard 3 replicas", 300),
        "appinsights": ("90 days", 100),
        "total": 2800
    }
}

config = configurations[(doc_size, ha_needed)]
```

### Step 3: Check Azure Quotas (1 min - AUTO)

```bash



az vm list-skus \
  --location "${REGION}" \
  --query "[?family=='StandardSv5'].capabilities[?name=='vCPUs'].value" \
  --output json




az cognitiveservices account list \
  --query "[?location=='${REGION}'].kind" \
  --output json
```

**If quota issue:**
```
âš ï¸  Region {region} has limited quota for OpenAI.

Available alternatives:
  â€¢ westus2 (quota: unlimited)
  â€¢ northeurope (quota: unlimited)
  â€¢ southeastasia (quota: 2 units)

Try different region? (Y/n)
```

### Step 4: Cost Breakdown (30 sec)

```
ðŸ“Š COST ANALYSIS

Configuration: {doc_size.upper()} | High Availability: {ha}

Service Costs (Monthly):
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Azure OpenAI: {openai_tier}           â”‚
â”‚   â€¢ Model: gpt-4o                  â”‚
â”‚   â€¢ Tokens: {tokens}/month              â”‚
â”‚   â€¢ Cost: ${openai_cost}/mo              â”‚
â”‚                                         â”‚
â”‚ Azure AI Search: {search_tier}         â”‚
â”‚   â€¢ Tier: Standard                      â”‚
â”‚   â€¢ Replicas: {replicas}                â”‚
â”‚   â€¢ Cost: ${search_cost}/mo              â”‚
â”‚                                         â”‚
â”‚ Application Insights: {ai_retention}  â”‚
â”‚   â€¢ Retention: {retention} days          â”‚
â”‚   â€¢ Cost: ${ai_cost}/mo                  â”‚
â”‚                                         â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ TOTAL MONTHLY: ${total}/mo               â”‚
â”‚ Annual: ${total * 12}                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Your Budget: ${user_budget}/mo
Difference: ${difference:+f"${difference} under budget" if difference > 0 else f"${abs(difference)} OVER budget"}
Status: {"âœ… FITS BUDGET" if total <= user_budget else "âš ï¸ EXCEEDS BUDGET"}
```

### Step 5: Validation Result (30 sec)

```
IF total_cost <= user_budget:
  âœ… Validation PASSED
  
  Your infrastructure fits your budget.
  Ready to deploy? (Y/n)

ELSE IF total_cost <= user_budget * 1.1:  # Within 10%
  âš ï¸ Validation YELLOW
  
  Configuration is ${difference} over budget (${percent}%).
  
  Options:
    A) Proceed anyway (slight overage)
    B) Reduce to smaller tier
    C) Cancel
  
  Your choice? (A/B/C)

ELSE:  # Way over budget
  âŒ Validation FAILED
  
  Configuration costs ${difference} more than budget.
  This is ${percent}% over.
  
  To fit budget, you need ONE of:
    â€¢ Reduce doc size (move cold docs to archive)
    â€¢ Increase budget to ${total}
    â€¢ Use smaller Azure region
    â€¢ Reduce high availability (use 1 replica)
  
  Retry with different params? (Y/n)
```

### Step 6: Save Report

```python
report = {
    "timestamp": "2026-05-13T10:30:00Z",
    "doc_size": "small",
    "budget_provided": 2000,
    "high_availability": False,
    "region": "eastus",
    "configuration": {
        "openai": {"tier": "S0", "cost": 1200},
        "search": {"tier": "Standard 1 replica", "cost": 200},
        "appinsights": {"retention": "30 days", "cost": 50}
    },
    "total_cost": 1450,
    "status": "PASSED",
    "quota_checks": {
        "region": "OK",
        "openai": "OK",
        "search": "OK"
    }
}



with open(f"outputs/validation-report-{timestamp}.json", "w") as f:
    json.dump(report, f, indent=2)

print(f"âœ… Report saved to outputs/validation-report-{timestamp}.json")
```

---

## Error Scenarios

### Over Budget
```
âŒ Configuration ($2,750/mo) exceeds budget ($2,000/mo)

To fit budget, try:
  1. Mark some docs as "archive" (lower tier)
  2. Reduce replicas: 3 â†’ 2 (saves $50)
  3. Use 30-day retention (save $50)

New estimate: $2,650 (-$100)
Still over. Proceed anyway? (Y/n)
```

### Region Quota Full
```
âš ï¸ Region eastus is at quota for OpenAI S0.

Alternatives:
  â€¢ westus2: âœ… Available (quota: 10 units)
  â€¢ northeurope: âœ… Available (quota: 5 units)
  â€¢ southeastasia: âš ï¸  Limited (quota: 2 units)

Use westus2 instead? (Y/n)
```

### Model Unavailable
```
âš ï¸ gpt-4o model not yet available in region southeastasia.

Recommendations:
  1. Try different region (see above)
  2. Use gpt-4-turbo as fallback (same cost)
  3. Wait for model availability (check Azure news)

Your choice? (1/2/3)
```

---

## Integration with Wizard

After validation PASSES, wizard can proceed:

```
âœ… Validation PASSED

Ready to deploy infrastructure? (Y/n)
â†’ Calls: rag-azure-setup.agent.md
```

If validation FAILS, stop:

```
âŒ Validation FAILED

Cannot proceed to deployment.
Fix issues above and try again.

Exit.
```

---

## Success Criteria

âœ… User sees clear cost breakdown

âœ… Quota issues identified BEFORE deployment

âœ… User can decide: proceed or adjust

âœ… No surprises later

