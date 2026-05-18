# [REPLACE: agent-name].agent.md Instructions

**Purpose:** [REPLACE: One-line summary of agent purpose]

**Called By:** [REPLACE: Which agents or user scenarios call this? Manual or orchestrated?]

**Expected Duration:** [REPLACE: Time estimate]

---

## ✅ MUST-DO Checklist

- [ ] [REPLACE: Verification 1 - Does X exist?]
- [ ] [REPLACE: Verification 2 - Is Y configured?]
- [ ] [REPLACE: Verification 3 - Can I access Z?]

---

## Prerequisites (Auto-Check)

```python
# BEFORE anything else:
import os
import subprocess

# Check 1: [REPLACE: Prerequisite 1]
result = subprocess.run(['[REPLACE: command]'], capture_output=True)
if result.returncode != 0:
    print("❌ [REPLACE: Error message]")
    exit(1)

# Check 2: [REPLACE: Prerequisite 2]
if not os.path.exists('[REPLACE: path]'):
    print("❌ [REPLACE: Path not found message]")
    exit(1)

print("✅ All prerequisites met")
```

---

## Phase-by-Phase Automation

### Phase 1: [REPLACE: Phase Name] (X min - AUTO)

**Purpose:** [REPLACE: What happens]

**Steps:**
1. [REPLACE: Step 1 with code example]

```python
# Example implementation
[REPLACE: Code snippet]
```

2. [REPLACE: Step 2]

```bash
# Example command
[REPLACE: Bash command]
```

**Validation:**
- ✅ [REPLACE: Validation check 1]
- ✅ [REPLACE: Validation check 2]

**If fails:**
```
Error: [REPLACE: Expected error]
Action: [REPLACE: Recovery step]
```

---

### Phase 2: [REPLACE: Phase Name] (X min - INTERACTIVE/AUTO)

**Purpose:** [REPLACE: What happens]

**User Prompts (if INTERACTIVE):**
```
Prompt 1: "[REPLACE: Question to user]"
  Input: [REPLACE: Expected input type]
  Default: [REPLACE: Default value if any]
  
Prompt 2: "[REPLACE: Question to user]"
  Options: [REPLACE: List options]
  Validation: [REPLACE: How to validate]
```

**Processing:**
1. [REPLACE: Processing step 1]
2. [REPLACE: Processing step 2]

```python
# Implementation
[REPLACE: Code snippet]
```

---

### Phase 3: [REPLACE: Phase Name] (X min - AUTO)

**Purpose:** [REPLACE: What happens]

**Steps:**
1. [REPLACE: Step 1]

```bash
# Example command
[REPLACE: Command]
```

**Expected Output:**
```
✅ [REPLACE: Success message]
📄 Created: [REPLACE: Output files]
```

---

## Expected Outputs

**Files Created:**
- `.env` - [REPLACE: What's written?]
- `outputs/[filename].json` - [REPLACE: Description]

**User Receives:**
- ✅ [REPLACE: What user sees]
- 📊 [REPLACE: Metrics/summary]
- 📝 [REPLACE: Any instructions?]

---

## Configuration

**Environment Variables (from `.env`):**
```
[REPLACE: VAR_NAME]=value
[REPLACE: VAR_NAME]=value
```

**User Configuration (prompted):**
```
Question 1: [REPLACE: What's asked?]
Question 2: [REPLACE: What's asked?]
```

**Computed/Derived:**
```
[REPLACE: What gets calculated based on above?]
```

---

## Troubleshooting

### Scenario 1: [REPLACE: Problem Description]

**User Sees:**
```
[REPLACE: Error message]
```

**Root Cause:**
[REPLACE: Why this happens]

**Fix:**
1. [REPLACE: Step 1]
2. [REPLACE: Step 2]
3. Retry the agent

**Prevention:**
[REPLACE: How to prevent this in future]

---

### Scenario 2: [REPLACE: Problem Description]

**User Sees:**
```
[REPLACE: Error message]
```

**Fix:**
[REPLACE: Solution steps]

---

## Implementation Notes

### Important Details
- [REPLACE: Implementation detail 1]
- [REPLACE: Implementation detail 2]
- [REPLACE: Edge case handling]

### Assumptions
- [REPLACE: Assumption 1]
- [REPLACE: Assumption 2]

### Dependencies
- Requires: [REPLACE: Agent/Skill dependency]
- Calls: [REPLACE: Other agent]
- Uses skill: [REPLACE: Skill name]

---

## Performance Considerations

**Optimization:**
- [REPLACE: What can be optimized?]
- [REPLACE: What to avoid?]

**Timeouts:**
- Default timeout: [REPLACE: X seconds]
- Increase if: [REPLACE: Condition]

---

## Security Considerations

**Sensitive Data:**
- [REPLACE: What secrets are used?]
- [REPLACE: Where are they stored?]
- [REPLACE: How are they protected?]

**Access Control:**
- [REPLACE: Who should run this?]
- [REPLACE: What permissions needed?]

---

## Monitoring & Observability

**Instrumentation:**
```python
from agent_instrumentation import MetricsCollector, instrument_call

collector = MetricsCollector(
    app_insights_key=os.getenv("APP_INSIGHTS_CONNECTION_STRING")
)

@instrument_call(collector, "[REPLACE: operation-name]")
def my_operation():
    pass
```

**Metrics Captured:**
- tokens_in, tokens_out
- latency_ms
- cost_usd
- errors (if any)

**Logs Saved:**
```
logs/[REPLACE: log-file].log
```

---

## Validation

**Before proceeding:**
- [ ] All prerequisites met
- [ ] User inputs validated
- [ ] Configuration correct
- [ ] No dry-run errors

**After completion:**
- [ ] All outputs exist
- [ ] Credentials saved to .env
- [ ] Summary generated
- [ ] Metrics logged

---

## References

- 📚 [Related Microsoft Learn Doc](https://learn.microsoft.com/...)
- 📋 [Related Skill](../skills/[skill-name]/SKILL.md)
- 🎯 [Related Agent](../agents/[agent-name].agent.md)
- 📖 [RAG Best Practices](../rag-best-practices.md)
