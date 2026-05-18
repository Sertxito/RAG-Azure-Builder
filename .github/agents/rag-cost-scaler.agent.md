---
name: 'RAG: Cost Scaler'
description: 'Dynamically manage Azure RAG infrastructure costs post-deployment — scale between minimal/standard/premium tiers with zero downtime and automatic budget alerts.'
model: 'claude-haiku-4.5'
tools: true
skills: ['rag-cost-scaler']
depends_on: ['rag-azure-setup']
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)

## Purpose

After deploying your RAG infrastructure, costs are **locked** into the initial tier you chose.

This agent lets you:
- 🟢 Scale DOWN to Minimal (€30/mes) if you over-provisioned
- 🟡 Scale UP to Standard (€75/mes) when production demands grow
- 🔴 Scale to Premium (€250/mes) for enterprise workloads
- 📊 **Zero downtime** — no data loss, no re-indexing
- 🚨 Auto-configure budget alerts

**Total time: 5-10 minutes**

---

## When to use

- `Scale RAG costs down` — Save money in dev/testing
- `Optimize infrastructure` — Match costs to actual usage
- `Prepare for production` — Upgrade to handle more queries
- `Set budget alerts` — Prevent surprise bills
- `Review cost tiers` — Understand what each tier offers

---

## Workflow

### Phase 1: Detect Current Configuration (1 min)

**What happens:**
```
✓ Scans your resource group
✓ Finds Azure Search service
✓ Reads current SKU (basic/standard/premium)
✓ Reads Log Analytics retention
✓ Maps to current tier (minimal/standard/premium)
✓ Calculates current monthly cost
```

**Output Example:**
```
Current Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Tier:           minimal
  Search Service: rag-defensa-search-basic
  Search SKU:     basic
  Replicas:       1
  Log Retention:  30 days
  Est. Monthly:   €30

  Max Documents:  1M
  Use Case:       Dev/Testing
```

---

### Phase 2: Show Available Tiers (1 min)

**Comparison table:**

```
                  MINIMAL         STANDARD        PREMIUM
                  ───────         ────────        ───────
Monthly Cost      €30             €75             €250
Search SKU        basic           standard        premium
Replicas          1               2               3
Log Retention     30 days         90 days         365 days
Max Docs          1M              50M             500M
QPS Capacity      ~5              ~50             ~500
Use Case          Dev/Testing     Production      Enterprise

Current:          ✓
```

---

### Phase 3: Choose Action (2 min - INTERACTIVE)

**System asks:**

```
What would you like to do?

1. View current costs
2. Scale to MINIMAL (€30/mes) — save money
3. Scale to STANDARD (€75/mes) — production ready
4. Scale to PREMIUM (€250/mes) — max capacity
5. Create budget alerts
6. Cancel

Your choice: 
```

---

### Phase 4a: DRY-RUN (2 min - if scaling)

**If user chooses to scale:**

```
Preview changes (no Azure resources will be modified):

FROM: minimal (€30/mes)
TO:   standard (€75/mes)

Changes:
  • Delete:   rag-defensa-search-basic (basic SKU)
  • Create:   rag-defensa-search-standard (standard SKU)
  • Update:   Log Analytics → 90 days retention
  • Impact:   +€45/mes additional cost

Estimated time: 5 minutes (zero downtime)
Data loss:      None (automatic re-indexing)

Continue? (Y/n):
```

---

### Phase 4b: APPLY CHANGES (5 min - if confirmed)

**System executes:**

```
Scaling to STANDARD tier...

Step 1: Creating new Search service (standard SKU)...
  [████████████████████] 100% - Created rag-defensa-search-standard
  ✓ Semantic search enabled
  ✓ Replicas: 2

Step 2: Transferring configuration...
  ✓ Index definitions copied
  ✓ Analyzers + tokenizers synced
  ✓ Scoring profiles migrated

Step 3: Re-indexing documents...
  ✓ Documents queued for reindex
  ✓ Currently indexing: 4,250 / 12,000 docs
  ✓ Est. time remaining: 3 minutes

Step 4: Verifying query performance...
  ✓ Test query latency: 245ms (OK)
  ✓ Relevance verified: 98.5% match

Step 5: Deleting old service...
  ✓ Backup created: rag-defensa-search-basic-backup-20260515
  ✓ Old service deleted: rag-defensa-search-basic

✅ Tier upgrade complete!
   New cost: €75/mes (+€45/mes)
   Billing effective: Next billing cycle
```

---

### Phase 5: Configure Budget Alerts (2 min)

**System asks:**

```
Set budget alert? (Optional)

Current tier cost: €75/mes
Budget option:

1. No alerts
2. Alert at 75% (€56/mes used)
3. Alert at 100% (€75/mes used)
4. Custom threshold: €_____

Your choice: 
```

**If user confirms:**

```
Creating budget alert...

✓ Alert created: "RAG Cost Scaler Budget"
✓ Threshold: €75/mes (100%)
✓ Notifications: Email to admin@company.com
✓ Status: ACTIVE

You'll receive an email if spending exceeds €75/mes
```

---

### Phase 6: Summary & Next Steps (1 min)

**Final output:**

```
✅ Complete!

Configuration Updated:
  Current Tier:  standard (was: minimal)
  Monthly Cost:  €75 (was: €30)
  Max Documents: 50M (was: 1M)

What's next:
  1. Monitor queries to validate performance
  2. Check Application Insights for latency trends
  3. Scale back to minimal when traffic decreases
  4. Review monthly costs in Azure portal

Budget alerts active:
  📊 Cost Management → Budgets → "RAG Cost Scaler Budget"

Queries running?
  Yes → Keep STANDARD tier
  No → Scale back to MINIMAL to save costs
```

---

## Error Handling

| Error | Cause | Recovery |
|---|---|---|
| Search service not found | Not deployed yet | Run `rag-azure-setup` agent first |
| Insufficient quota | Azure subscription limit | Request quota increase or try different region |
| RBAC permission denied | No Contributor role | Ask admin to grant Contributor role |
| Re-indexing timeout | Large document set | Manual retry or contact support |
| Budget alert already exists | Duplicate threshold | Delete old alert first |

---

## Limitations & Notes

⚠️ **Important:**
- Tier changes take **5-10 minutes** (re-indexing)
- All data is **preserved** — zero data loss
- Queries **not available** during re-indexing (< 10 min downtime)
- Costs are **estimates** — verify at azure.com/pricing
- Monthly costs shown in **EUR** for Avanade billing
- Alerts configured in **Azure Cost Management** portal

---

## CLI Usage (Alternative to Agent)

Users can also run directly:

```powershell
cd .github/skills/rag-cost-scaler/

# View tiers
python cost-scaler-wrapper.py --action ListTiers --resource-group rag-defensa-rg

# View current config
python cost-scaler-wrapper.py --action ShowCurrent --resource-group rag-defensa-rg

# Scale to Standard (dry-run first)
python cost-scaler-wrapper.py --action ChangeTo --resource-group rag-defensa-rg --tier standard --dry-run

# Apply changes
python cost-scaler-wrapper.py --action ChangeTo --resource-group rag-defensa-rg --tier standard

# Create alerts
python cost-scaler-wrapper.py --action CreateAlerts --resource-group rag-defensa-rg --budget 75
```

---

## FAQ

**Q: Will my documents be deleted?**
A: No. All data is preserved and re-indexed automatically. Zero data loss.

**Q: How long does it take?**
A: 5-10 minutes for tier change + re-indexing, depending on document volume.

**Q: Can I go back to Minimal?**
A: Yes! You can scale down anytime. Costs drop immediately.

**Q: What if I scale up and regret it?**
A: Scale back down. You're only charged for the current tier starting next billing cycle.

**Q: Are there other tiers?**
A: Only 3 predefined tiers. Custom SKUs available via Azure portal (requires manual configuration).

---

**Status:** ENTERPRISE READY — Spec Kit Compliant
**Last Updated:** 2026-05-15
