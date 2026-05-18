---
name: '[REPLACE: Agent Display Name]'
description: '[REPLACE: One-line purpose statement]'
model: 'claude-haiku-4.5'
tools: true
skills:
  - '[REPLACE: skill-name-1]'
  - '[REPLACE: skill-name-2]'
depends_on: []
---

# [REPLACE: Agent Display Name]

## Purpose

[REPLACE: 2-3 sentences describing what this agent does]

✅ [What this agent accomplishes - 1]  
✅ [What this agent accomplishes - 2]  
✅ [What this agent accomplishes - 3]  

---

## When to use

```bash
copilot-cli run .github/agents/[REPLACE: filename].agent.md
```

**Use this agent when:**
- [REPLACE: Trigger condition 1]
- [REPLACE: Trigger condition 2]
- [REPLACE: Trigger condition 3]

**Do NOT use when:**
- [REPLACE: Avoid condition 1]
- [REPLACE: Avoid condition 2]

---

## Expected Duration

[REPLACE: Time estimate] minutes

**Breakdown:**
- Phase 1: [X] minutes
- Phase 2: [X] minutes
- Phase 3: [X] minutes

---

## Workflow

### Phase 1: [REPLACE: Phase Name]

[REPLACE: Description of what happens in this phase]

```bash
# Example command or output
[REPLACE: Example]
```

**Checklist:**
- [ ] [REPLACE: Verification step 1]
- [ ] [REPLACE: Verification step 2]
- [ ] [REPLACE: Verification step 3]

---

### Phase 2: [REPLACE: Phase Name]

[REPLACE: Description of what happens in this phase]

**Input:**
```
[REPLACE: What user provides]
```

**Output:**
```
[REPLACE: What gets created/generated]
```

---

### Phase 3: [REPLACE: Phase Name]

[REPLACE: Description of what happens in this phase]

---

## Expected Outputs

- 📄 `outputs/[file1].json` - [REPLACE: Description]
- 📄 `outputs/[file2].json` - [REPLACE: Description]
- 📝 `.env` - Updated with credentials (append mode)

---

## Configuration

[REPLACE: If agent takes parameters or reads from .env]

```bash
# Environment variables (from .env)
AZURE_SUBSCRIPTION_ID=<your-subscription-id>
AZURE_RESOURCE_GROUP=<resource-group-name>
AZURE_REGION=<region>
[REPLACE: Other vars]
```

---

## Troubleshooting

### Issue: [REPLACE: Common Error 1]

**Symptoms:**
```
[REPLACE: Error message]
```

**Solution:**
1. [REPLACE: Step 1]
2. [REPLACE: Step 2]
3. Retry: `copilot-cli run .github/agents/[filename].agent.md`

---

### Issue: [REPLACE: Common Error 2]

**Symptoms:**
```
[REPLACE: Error message]
```

**Solution:**
1. [REPLACE: Step 1]
2. [REPLACE: Step 2]

---

## Related Agents

- [RAG: Other Agent](rag-other.agent.md) - [REPLACE: Relationship]
- [RAG: Another Agent](rag-another.agent.md) - [REPLACE: Relationship]

---

## References

- 📚 [Official Documentation Link](https://learn.microsoft.com/...)
- 📋 [Instructions](../instructions/agent-[slug].instructions.md)
- 🎯 [Related Skill](../skills/[skill-name]/SKILL.md)
