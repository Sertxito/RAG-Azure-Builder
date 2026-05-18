---
name: 'rag-architecture-optimizer'
description: 'Validates and optimizes Azure deployment architecture for cost-efficiency and performance. Reviews service tiers, scaling, redundancy, and recommends right-sizing before deployment.'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





## Purpose

Pre-deployment validation and optimization of Azure infrastructure to prevent over-provisioning or under-sizing that could lead to unnecessary costs or reliability issues.

## When to Use

- Before deploying with `main.bicep`
- When evaluating different tier options (Standard vs Premium)
- When planning for production scale
- When cost is a constraint

## Key Validations

### 1. Service Tier Sizing
- **Azure OpenAI**: S0 (standard) is sufficient for most RAG workloads. E0 (enterprise) unnecessary unless > 100 req/sec
- **Azure Search**: Standard tier minimum. Premium only if > 10M documents or < 10ms p50 latency required
- **App Insights**: Standard retention (30 days) fits baseline RAG operations. Premium only for large-scale multi-region

### 2. Scaling Configuration
- **Replicas**: 1 for baseline RAG, 3+ for production HA
- **Partitions**: 1 for < 500GB, scale up only if search latency > SLO
- **Concurrent instances**: Container App starts at 1, auto-scales based on metrics

### 3. Redundancy Level
- **Geo-redundancy**: Not needed for baseline single-region RAG deployments
- **Availability Zones**: Only if uptime SLA > 99.9%
- **Failover**: Optional for baseline deployments (adds $500-1000/month)

## Usage in Pipeline

```python


class AzureArchitectOptimizer:
    def validate_deployment(self, bicep_config: Dict) -> Dict:
        """
        Validate deployment config before actual deploy
        Returns: {
            'valid': bool,
            'tier_recommendations': List[str],
            'cost_warnings': List[str],
            'suggested_adjustments': Dict
        }
        """
        findings = {
            'valid': True,
            'tier_recommendations': [],
            'cost_warnings': [],
            'suggested_adjustments': {}
        }

        # Check OpenAI tier
        openai_tier = bicep_config.get('openaiTier', 'S0')
        if openai_tier == 'E0' and bicep_config.get('expectedRPS', 0) < 50:
            findings['tier_recommendations'].append(
                "OpenAI: E0 tier is overkill for < 50 RPS. Use S0 instead (-$600/month)"
            )
            findings['suggested_adjustments']['openaiTier'] = 'S0'

        # Check Search tier
        search_tier = bicep_config.get('searchTier', 'standard')
        search_replicas = bicep_config.get('searchReplicas', 1)

        if search_tier == 'premium' and search_replicas == 1:
            findings['cost_warnings'].append(
                "Search: Premium tier with 1 replica is wasteful. Use Standard + 2 replicas instead"
            )
            findings['suggested_adjustments']['searchTier'] = 'standard'
            findings['suggested_adjustments']['searchReplicas'] = 2

        # Check App Insights
        app_insights_retention = bicep_config.get('appInsightsRetention', 30)
        if app_insights_retention > 90:
            findings['cost_warnings'].append(
                f"App Insights: {app_insights_retention}-day retention adds ${(app_insights_retention - 30) * 0.05:.0f}/month"
            )

        return findings
```

## Optimization Checklist

- [ ] OpenAI tier matches traffic volume
- [ ] Search replicas scaled appropriately (not always 3+)
- [ ] Partitions aligned with data size
- [ ] Regional distribution justified
- [ ] Redundancy level matches SLA requirements
- [ ] Auto-scaling policies defined
- [ ] No unused resources (old indexes, extra deployments)

## Output Format

```json
{
  "status": "valid_with_optimizations",
  "cost_impact": {
    "current_estimated_monthly": 3150,
    "optimized_estimated_monthly": 1200,
    "savings": "$1,950/month (-62%)"
  },
  "recommendations": [
    {
      "resource": "OpenAI",
      "current": "E0 (enterprise)",
      "recommended": "S0 (standard)",
      "reason": "Your peak is 25 RPS, S0 handles up to 240 RPS",
      "monthly_savings": "$600"
    },
    {
      "resource": "Search",
      "current": "premium, 1 replica",
      "recommended": "standard, 2 replicas",
      "reason": "Premium for single-node is anti-pattern. Standard + replicas is HA + cost-effective",
      "monthly_savings": "$400"
    }
  ]
}
```

---

**Recommendation**: Always run this optimizer BEFORE deploying. It catches 90% of over-provisioning mistakes.

