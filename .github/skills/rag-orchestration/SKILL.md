---
name: 'rag-orchestration'
description: 'Complete automated 8-phase RAG setup orchestrator for new projects'
applyTo: '**/*.agent.md'
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





**Status:** Production  
**Version:** 1.0  
**Last Updated:** May 13, 2026

---

## Purpose

Complete automation orchestrator for RAG (Retrieval Augmented Generation) setup. Takes a user from "I have documents" to "I can query my RAG" in 8 phases with zero manual Azure portal interaction.

This skill:
- âœ… **8-Phase Automation**: Interview â†’ Recommend â†’ Validate â†’ Deploy â†’ Index â†’ Configure â†’ Test â†’ Summary
- âœ… **Configuration-Driven**: Auto-selects infrastructure tiers based on document size
- âœ… **Cost-Aware**: Validates budget before deployment, prevents expensive mistakes
- âœ… **Document Auto-Discovery**: Scans `knowledge/` folder and indexes all formats (PDF, Word, Excel, Markdown, Code, PowerPoint)
- âœ… **Credential Generation**: Auto-creates `.env` with Azure endpoint templates
- âœ… **Session Logging**: Saves orchestration logs to JSON for audit trail

---

## Use Cases

### When to use this skill

- **New RAG Project**: Starting from zero with documentation files
- **First-Time Setup**: "I have docs, make it work" scenario
- **Automated Onboarding**: Need a repeatable, hands-free setup process
- **Multiple Projects**: Can run this for different knowledge sources (next project just changes `knowledge/` folder)
- **Validation/PoC**: Quick validation that RAG works before production investment

### When NOT to use

- Existing deployments needing updates (use individual phase skills)
- Complex multi-tenant scenarios
- Highly customized Azure configurations

---

## 8-Phase Workflow

### Phase 1: Interview (5 min)
- Collects 5 questions: project name, description, doc size, budget, region
- **Output**: User configuration dict

### Phase 2: Recommend (1 min)
- Auto-selects Azure tier config based on document size
- **Output**: Infrastructure recommendations (OpenAI tier, Search tier, cost estimate)

### Phase 3: Validate (2 min)
- Calls `rag-cost-analyst` skill to validate budget vs actual cost
- Checks Azure quotas in target region
- **Output**: Go/No-go decision with warnings

### Phase 4: Deploy (10-15 min)
- Deploys via Bicep templates (or coordinator can inject custom deployment logic)
- **Output**: Resource endpoints (OpenAI, Search, AppInsights)

### Phase 5: Index (5 min)
- Scans `knowledge/` folder (pdfs, procedimientos, codigo, presentaciones)
- Counts documents and mock-chunks (300 tokens, 50 overlap)
- **Output**: Document inventory

### Phase 6: Configure (1 min)
- Generates `.env` file with credential templates
- **Output**: `.env` ready for user to fill credentials

### Phase 7: Test (2 min)
- Mock-tests connections to Azure OpenAI, Search, AppInsights
- **Output**: Connection validation report

### Phase 8: Summary (1 min)
- Displays setup complete summary
- Saves session log to JSON for audit
- **Output**: Next-steps instructions

---

## Python Usage

```python
from pathlib import Path
import sys



sys.path.insert(0, str(Path(__file__).parent / ".github" / "skills" / "rag-orchestration"))

from orchestrator import RAGOrchestrator



orchestrator = RAGOrchestrator()
exit_code = orchestrator.run()
```

### Direct Execution

```bash


python .github/skills/rag-orchestration/orchestrator.py



python run-rag.py --agent onboarding
```

---

## Input Parameters

No parameters. The skill performs interactive prompts for:

| Question | Example | Options |
|----------|---------|---------|
| Project Name | `rag-mensadef` | any string |
| Description | `Document Q&A for MENSADEF` | any string |
| Doc Size | `medium` | small, medium, large, enterprise |
| Budget (USD) | `2000` | numeric |
| Region | `eastus` | Azure regions |

---

## Output

### Session Log (JSON)

Saved to `outputs/orchestration-{timestamp}.json`:

```json
{
  "started_at": "2026-05-13T22:59:08.123456",
  "completed_at": "2026-05-13T23:15:22.456789",
  "status": "completed",
  "phases": {
    "interview": {"status": "completed"},
    "recommend": {"status": "completed"},
    "validate": {"status": "completed"},
    "deploy": {"status": "completed"},
    "index": {"status": "completed"},
    "configure": {"status": "completed"},
    "test": {"status": "completed"},
    "summary": {"status": "completed"}
  }
}
```

### Files Created

- `.env` - Credential template file
- `logs/rag-orchestration.log` - Execution log
- `outputs/orchestration-{timestamp}.json` - Session audit trail

---

## Dependencies

### Required
- Python 3.10+
- UTF-8 encoding support

### Optional
- `rag-cost-analyst` skill (if missing, Phase 3 skips cost validation)
- `rag-deployment-templates` skill (if missing, Phase 4 mocks deployment)

### Fallback Behavior
If optional skills are unavailable, orchestration continues with warnings and mock data.

---

## Folder Structure Expected

```
project-root/
â”œâ”€â”€ .github/skills/rag-orchestration/
â”‚   â”œâ”€â”€ orchestrator.py       â† This module
â”‚   â””â”€â”€ SKILL.md              â† Documentation
â”œâ”€â”€ knowledge/                â† User documents (auto-discovered)
â”‚   â”œâ”€â”€ pdfs/
â”‚   â”œâ”€â”€ procedimientos/
â”‚   â”œâ”€â”€ codigo/
â”‚   â””â”€â”€ presentaciones/
â”œâ”€â”€ logs/                     â† Auto-created
â””â”€â”€ outputs/                  â† Auto-created
```

---

## Configuration

### Recommendations Table (Auto-applied based on doc size)

| Doc Size | OpenAI Tier | Search Tier | Est. Cost/mo |
|----------|-------------|------------|-------------|
| small | S0 | standard | $1,450 |
| medium | S0 | standard | $1,500 |
| large | S1 | standard | $2,750 |
| enterprise | S1 | premium | $4,200 |

Modify the RECOMMENDATIONS dict in `orchestrator.py` to customize.

---

## Logs

Execution logs written to:
- **File**: `logs/rag-orchestration.log` (UTF-8)
- **Console**: Real-time phase output

---

## Error Handling

- Missing `knowledge/` folder â†’ Auto-created with subfolder structure
- Missing cost analyzer â†’ Phase 3 skips validation
- Budget exceeded â†’ Phase 2 warns but continues
- Azure quotas issues â†’ Phase 3 logs warning
- File I/O errors â†’ Logged but continue

---

## For Next Project

To recreate this RAG with different knowledge source:

1. **Copy entire `.github/` folder** (agents, instructions, skills)
2. **Replace `knowledge/` folder** with your documents
3. **Run**: `python run-rag.py --agent onboarding`

Everything else is automated and reusable.

---

## Example Output

```
============================================================
RAG ORCHESTRATION WIZARD - 8 PHASES
============================================================

=== RAG Orchestration Wizard ===

I'll ask 5 questions to setup your RAG system.

1. Project name [rag-builder]: rag-mensadef
2. What does this system do: Document Q&A for MENSADEF
3. Document size:
   small (< 1 GB)
   medium (1-10 GB)
   large (10-50 GB)
   enterprise (> 50 GB)
Choose: medium

4. Monthly budget USD [2000]: 3000

5. Azure region [eastus]: 
Choose: eastus

--- Analyzing requirements ---

RECOMMENDED:
  Azure OpenAI: S0 tier
  Azure Search: standard
  Est. Cost:    $1500/month
  Your Budget:  $3000/month
  Status:       OK

--- Validating ---

Budget Check:  OK
Azure Quotas:  OK

... [phases 4-8] ...

============================================================
SETUP COMPLETE!
============================================================

Project:     rag-mensadef
Region:      eastus
Monthly Cost: $1500

Next Steps:
1. Add documents to knowledge/
2. Update .env with Azure credentials
3. Run RAG chat interface
============================================================

Session log: outputs/orchestration-20260513-225922.json
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| UnicodeEncodeError | Python version 3.10+ required; UTF-8 configured at module start |
| Cost analyzer not found | Check `rag-cost-analyst/` skill exists in `.github/skills/` |
| `knowledge/` folder empty | Add documents to `knowledge/pdfs`, `procedimientos`, etc. |
| `.env` file not created | Check write permissions in project root |

---

## Related Skills

- [`rag-cost-analyst`](../rag-cost-analyst/SKILL.md) - Cost validation (Phase 3)
- [`rag-deployment-templates`](../rag-deployment-templates/SKILL.md) - Bicep deployment (Phase 4)
- [`rag-rag-rag-agent-instrumentation`](../rag-rag-rag-agent-instrumentation/SKILL.md) - Observability (Phase 7+)

---

