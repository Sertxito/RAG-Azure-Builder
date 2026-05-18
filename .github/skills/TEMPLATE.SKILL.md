---
name: '[REPLACE: skill-name]'
description: '[REPLACE: One-line description of what this skill does]'
applyTo: '[REPLACE: Glob pattern, e.g., "**/*.py, **/*.agent.md"]'
---

# Skill: [REPLACE: Skill Display Name]

**Status:** [REPLACE: Production / Preview / Development]  
**Version:** 1.0  
**Last Updated:** [REPLACE: Date]

---

## Purpose

[REPLACE: 2-3 sentences explaining what this skill provides]

This skill:
- ✅ [REPLACE: Capability 1]
- ✅ [REPLACE: Capability 2]
- ✅ [REPLACE: Capability 3]

---

## Use Cases

### When to use this skill

- [REPLACE: Scenario 1]
- [REPLACE: Scenario 2]
- [REPLACE: Scenario 3]

### When NOT to use

- [REPLACE: Anti-pattern 1]
- [REPLACE: Anti-pattern 2]

---

## Usage

### For Agents

Declare in agent frontmatter:

```yaml
---
name: 'My Agent'
skills:
  - '[REPLACE: skill-name]'
---
```

### For Python Code

```python
from [REPLACE: module_name] import [REPLACE: Class/Function]

# Initialize
[REPLACE: init_code]

# Use
[REPLACE: usage_code]
```

### For Bicep/IaC

```bicep
module [REPLACE: module_var] 'br/public:[REPLACE: registry]/[REPLACE: module]:1.0' = {
  name: '[REPLACE: deployment-name]'
  params: {
    [REPLACE: param1]: '[REPLACE: value]'
    [REPLACE: param2]: '[REPLACE: value]'
  }
}
```

---

## Installation

### Prerequisites

- [REPLACE: Prerequisite 1]
- [REPLACE: Prerequisite 2]

### Setup

```bash
# Install dependencies
pip install [REPLACE: package-name]

# Or for bicep
bicep registry login [REPLACE: registry-url]
```

---

## Features

### Feature 1: [REPLACE: Feature Name]

**Description:** [REPLACE: What does it do?]

**Example:**
```python
# Code example
[REPLACE: Example usage]
```

**Output:**
```
[REPLACE: Example output]
```

---

### Feature 2: [REPLACE: Feature Name]

**Description:** [REPLACE: What does it do?]

**Example:**
```python
# Code example
[REPLACE: Example usage]
```

---

## Configuration

### Required Settings

```python
[REPLACE: CONFIG_PARAM_1] = "[REPLACE: value]"
[REPLACE: CONFIG_PARAM_2] = "[REPLACE: value]"
```

### Optional Settings

```python
[REPLACE: OPTIONAL_PARAM_1] = "[REPLACE: default_value]"
[REPLACE: OPTIONAL_PARAM_2] = "[REPLACE: default_value]"
```

---

## Outputs / Deliverables

This skill creates/generates:

- 📄 [REPLACE: Output 1] - Description
- 📄 [REPLACE: Output 2] - Description
- 🔧 [REPLACE: Output 3] - Description

**Example Output:**
```json
[REPLACE: Example JSON/output]
```

---

## Cost Estimate

### Monthly Cost (Example Scenario)

```
[REPLACE: Resource 1]: $XXX
[REPLACE: Resource 2]: $XXX
[REPLACE: Resource 3]: $XXX
──────────────────────────
TOTAL: $XXX/month
```

### Cost Optimization

- [REPLACE: Strategy 1]
- [REPLACE: Strategy 2]
- [REPLACE: Strategy 3]

---

## Troubleshooting

### Issue: [REPLACE: Common Problem 1]

**Symptoms:**
```
[REPLACE: Error message]
```

**Cause:**
[REPLACE: Why does this happen?]

**Solution:**
```bash
[REPLACE: Fix steps]
```

---

### Issue: [REPLACE: Common Problem 2]

**Symptoms:**
```
[REPLACE: Error message]
```

**Solution:**
[REPLACE: Fix steps]

---

## Best Practices

1. **[REPLACE: Best Practice 1]**
   - [REPLACE: Explanation]
   - [REPLACE: Example]

2. **[REPLACE: Best Practice 2]**
   - [REPLACE: Explanation]
   - [REPLACE: Example]

3. **[REPLACE: Best Practice 3]**
   - [REPLACE: Explanation]
   - [REPLACE: Example]

---

## Performance Considerations

### Optimization Tips

- [REPLACE: Tip 1]
- [REPLACE: Tip 2]

### Scalability

[REPLACE: How does this scale? What are the limits?]

### Caching/Memoization

[REPLACE: What can be cached?]

---

## Security & Compliance

### Security Considerations

- [REPLACE: Security aspect 1]
- [REPLACE: Security aspect 2]

### Compliance

- [REPLACE: Compliance requirement 1]
- [REPLACE: Compliance requirement 2]

### Access Control

[REPLACE: Who should have access to this skill?]

---

## Integration Examples

### Example 1: [REPLACE: Scenario]

```python
# Full working example
[REPLACE: Complete code example showing how to use the skill]
```

---

### Example 2: [REPLACE: Scenario]

```python
# Another example
[REPLACE: Another complete code example]
```

---

## API Reference

### Function/Class: [REPLACE: Name]

```python
def [REPLACE: function_name](
    param1: str,          # [REPLACE: description]
    param2: int = 10,     # [REPLACE: description]
    **kwargs
) -> [REPLACE: return_type]:
    """
    [REPLACE: Detailed docstring with examples]
    """
```

**Parameters:**
- `[REPLACE: param1]` (str): [REPLACE: description]
- `[REPLACE: param2]` (int): [REPLACE: description, default=...]

**Returns:**
- [REPLACE: Return type and description]

**Raises:**
- `[REPLACE: ExceptionType]`: When [REPLACE: condition]

**Example:**
```python
[REPLACE: Usage example]
```

---

## Testing

### Unit Tests

```bash
# Run tests
pytest tests/test_[REPLACE: module].py

# Run with coverage
pytest --cov=. tests/
```

### Integration Tests

[REPLACE: How to test this skill end-to-end?]

---

## Contributing

To extend or modify this skill:

1. Update [REPLACE: Main module]
2. Add tests in `tests/`
3. Update documentation
4. Submit PR

---

## Related Skills

- [REPLACE: Related Skill 1](../related-skill-1/SKILL.md)
- [REPLACE: Related Skill 2](../related-skill-2/SKILL.md)

---

## References

- 📚 [Official Documentation](https://learn.microsoft.com/...)
- 🔗 [GitHub Repository](https://github.com/...)
- 💡 [Blog Post / Tutorial](https://example.com)
- 📖 [API Reference](https://docs.example.com)

---

## Support & Feedback

- 🐛 Report bugs: [REPLACE: Issue tracker]
- 💬 Ask questions: [REPLACE: Discussion forum]
- ⭐ Suggest features: [REPLACE: Feature request]

---

**Version:** 1.0  
**Last Updated:** [REPLACE: Date]  
**Maintainer:** [REPLACE: Team/Person]
