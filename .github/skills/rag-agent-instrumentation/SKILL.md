---
name: 'rag-agent-instrumentation'
description: 'Reusable Python modules for instrumenting agents: metrics collection, Application Insights integration, logging with observability. Used by all agents to capture tokens, latency, cost, errors.'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





**Bundled assets**: `instrumentation.py`, `metrics_collector.py`

## Purpose

Provide reusable Python utilities for instrumenting any agent with:
- Token consumption tracking
- Latency measurement
- Cost calculation
- Application Insights integration
- Structured logging

## Usage

Import in any agent or script:

```python
from agent_instrumentation import MetricsCollector, instrument_call

collector = MetricsCollector(
    app_insights_key=os.getenv("APP_INSIGHTS_CONNECTION_STRING")
)

@instrument_call(collector, "my_agent")
def my_agent_function():
    # Automatically captures timing, tokens, errors
    pass
```

## Exported functions

- `MetricsCollector` â€” Main class for collecting metrics
- `instrument_call()` â€” Decorator for auto-instrumentation
- `calculate_token_cost()` â€” Pricing calculator by model
- `log_to_app_insights()` â€” Send custom events

## Used by

- `rag-onboarding.agent.md`
- `rag-validate-deployment.agent.md`
- `rag-azure-setup.agent.md`
- `rag-indexer-specialist.agent.md`
- `rag-chat.agent.md`
- `rag-clone-new-project.agent.md`
- Any custom agent that needs observability

