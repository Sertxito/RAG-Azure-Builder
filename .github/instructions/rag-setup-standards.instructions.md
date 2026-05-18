---
description: 'RAG setup standards for observability, error handling, and logging consistency across agents and scripts.'
applyTo: '**/*.py, **/*.agent.md'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)

# Instruction: RAG Setup Standards





## Observability Requirements

All agents and scripts MUST:

### 1. Logging

```python
import logging
logger = logging.getLogger(__name__)



logger.debug("Detailed execution info")        # Dev troubleshooting
logger.info("Step completed")                  # Normal progress
logger.warning("Potential issue")              # Non-blocking
logger.error("Operation failed, may recover") # Recoverable
```

### 2. Metrics Collection

Use `MetricsCollector` from rag-rag-rag-agent-instrumentation skill:

```python
from agent_instrumentation import MetricsCollector, instrument_call

collector = MetricsCollector(app_insights_key=os.getenv("APP_INSIGHTS_CONNECTION_STRING"))

@instrument_call(collector, "my_agent")
def my_function():
    pass











```

### 3. Error Handling

```python
try:
    # Operation
    pass
except TimeoutError:
    logger.error("Operation timed out", extra={"timeout_seconds": 30})
    # Retry with backoff
except ValueError as e:
    logger.warning(f"Invalid input: {e}")
    # Use default or fallback
except Exception as e:
    logger.error(f"Unexpected error: {e}", exc_info=True)
    # Re-raise after logging full context
    raise
```

### 4. Structured Logging

```python


logger.info("Agent executed", extra={
    "agent": "summary",
    "tokens_in": 1050,
    "latency_ms": 2100,
    "model": "gpt-4o"
})



logger.info(f"Agent summary ran in {latency_ms}ms")  # Bad
```

## Code Standards

### Python Scripts

- Use type hints: `def execute(query: str, context: str) -> Dict[str, Any]`
- Docstrings for all functions
- Class names: `PascalCase` (e.g., `MonolithicAgent`)
- Function names: `snake_case` (e.g., `execute_agent`)
- Constants: `UPPER_CASE` (e.g., `MAX_RETRIES`)

### Agent Markdown (.agent.md)

- Include YAML frontmatter with: `name`, `description`, `model`, `tools`
- Clear "When to use" section
- Step-by-step workflow with timing estimates
- Error handling table
- Expected outputs documented

## Testing

- All agents: test with `--verbose` flag
- All scripts: include `--validate` precheck
- RAG dry-runs: execute 3x to validate stability (< 20% variation)

## Deployment Checklist

Before running RAG workflows:

- [ ] `.env` configured with all Azure credentials
- [ ] Azure resources deployed (run `azure-setup-specialist`)
- [ ] RAG index created (run `rag-indexer-specialist`)
- [ ] Validation passed: `python scripts/validate_setup.py --verbose`
- [ ] All metrics output paths exist: `outputs/`
- [ ] Logs file configured: `outputs/rag.log`

## Output Format

All agents must generate JSON or structured output in `outputs/`:

```json
{
  "timestamp": "2024-05-10T14:30:00Z",
  "agent": "summary",
  "status": "success",
  "metrics": {
    "tokens_in": 1050,
    "tokens_out": 380,
    "latency_ms": 2100,
    "cost_usd": 0.0010
  },
  "output": "..."
}
```

---

**Applies to**: All `.py` scripts and `.agent.md` files
**Enforced by**: rag-onboarding.agent.md and rag-clone-new-project.agent.md

