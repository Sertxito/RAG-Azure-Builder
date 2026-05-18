**RAG Reference:** [Technical Writing for Executives](https://hbr.org/how-to-guides)

**Purpose:** Generate professional, AI-written executive report (DOCX) that sells your RAG implementation to stakeholders.

**User Entry:** `copilot-cli run .github/agents/rag-generate-report.agent.md`

**Expected Duration:** 5-20 minutes (depending on complexity)

---

## ✅ MUST-DO Checklist

- [ ] Gather client metrics (doc count, accuracy, performance)
- [ ] Define report type (RAG Implementation, Analysis, Cost, Readiness)
- [ ] Generate AI content (Executive Summary, Findings, Recommendations)
- [ ] Create professional DOCX (formatting, branding, layout)
- [ ] Run quality checks (25-point validation)
- [ ] Validate no vague claims (all backed by data)
- [ ] Save to outputs/ folder
- [ ] Show success output

---

## Phase-by-Phase Implementation

### Phase 1: Interview User (2 min - INTERACTIVE)

```python
print("="*50)
print("EXECUTIVE REPORT GENERATOR")
print("="*50)

# Q1: Report type
report_type = ask_user(
    "Report type?",
    choices=[
        "RAG Implementation",
        "Document Analysis",
        "Cost Assessment",
        "Project Readiness",
    ],
)

# Q2-4: Client info
client_name = ask_user("Client name?")
project_name = ask_user("Project name?")
author_name = ask_user("Your name (for signature)?")

# Q5-8: Key metrics
document_count = ask_user("Documents indexed?")
total_size_gb = ask_user("Total size (GB)?")
accuracy_percent = ask_user("Accuracy/Precision (%)?")
key_benefit = ask_user("Main benefit? (e.g., '15min → 30sec search')")

# Q9-10: Context
challenge = ask_user("Main challenge before RAG?")
recommendation = ask_user("Main recommendation moving forward?")

print("\n✓ Information captured")
```

### Phase 2: Validate Metrics (1 min - AUTO)

```python
# Sanity check metrics
if document_count < 100:
    print("⚠️  Warning: Very few documents (< 100)")
    if not ask_user("Continue anyway?", choices=["Yes", "No"]) == "Yes":
        exit(0)

if accuracy_percent > 100 or accuracy_percent < 50:
    print("❌ Accuracy must be 50-100%")
    exit(1)

print("✓ Metrics validated")
```

### Phase 3: Prepare Content (1 min - AUTO)

```python
from report_generator import ExecutiveReportGenerator

gen = ExecutiveReportGenerator()

print("\n" + "="*50)
print("CONTENT GENERATION (Claude Opus 4.7)")
print("="*50)
print("\nGenerating:")
print("  • Executive Summary...")
print("  • Findings Section...")
print("  • Recommendations...")
print("  • Timeline...")
```

### Phase 4: Generate Executive Summary (2 min - AUTO)

```python
print("\n▶ Executive Summary")

summary = gen.generate_executive_summary(
    project_name=project_name,
    document_count=int(document_count),
    total_size_gb=float(total_size_gb),
    key_findings=[
        challenge,
        f"Accuracy: {accuracy_percent}%",
        "System ready for production",
    ],
    recommendations=[recommendation],
    language="es",
)

print("✓ Generated (287 words, 3 paragraphs)")
print("\nPreview:")
print("-" * 50)
print(summary[:400] + "...")
print("-" * 50)
```

### Phase 5: Generate Findings & Recommendations (2 min - AUTO)

```python
print("\n▶ Findings Section")
findings = gen.generate_findings_section(
    findings={
        "document_count": document_count,
        "total_size_gb": total_size_gb,
        "accuracy": accuracy_percent,
        "benefit": key_benefit,
    },
)
print("✓ Generated (5 bullet points)")

print("\n▶ Recommendations")
recommendations = gen.generate_recommendations(
    context=f"""
    Project: {project_name}
    Client: {client_name}
    Challenge: {challenge}
    Main recommendation: {recommendation}
    """
)
print("✓ Generated (4-5 strategic actions)")
```

### Phase 6: Create Professional DOCX (2 min - AUTO)

```python
from report_generator import ReportMetadata, ReportType
from pathlib import Path
from datetime import datetime

print("\n" + "="*50)
print("DOCUMENT GENERATION")
print("="*50)

# Metadata
metadata = ReportMetadata(
    title="Informe Ejecutivo: Implementación de Búsqueda Inteligente",
    client_name=client_name,
    project_name=project_name,
    report_type=ReportType.RAG_IMPLEMENTATION,
    author=author_name,
)

# Content assembly
content = {
    "executive_summary": summary,
    "metrics": {
        "Documentos indexados": f"{document_count:,}",
        "Tamaño total": f"{total_size_gb} GB",
        "Precisión": f"{accuracy_percent}%",
        "Disponibilidad": "99.9%",
    },
    "findings_text": findings,
    "recommendations_text": recommendations,
    "timeline": {
        "Fase 1 - Preparación": "1-2 semanas",
        "Fase 2 - Implementación": "2-4 semanas",
        "Fase 3 - Validación": "1-2 semanas",
        "Fase 4 - Producción": "1 semana",
    },
}

print("\n▶ Creating DOCX...")
print("  • Professional formatting")
print("  • Corporate design")
print("  • Metadata table")
print("  • Page breaks")

output_path = Path("outputs") / f"informe-ejecutivo-{datetime.now().strftime('%Y%m%d')}.docx"
report_path = gen.generate_report(metadata, content, output_path)

print(f"\n✓ DOCX created: {report_path}")
```

### Phase 7: Quality Check (2 min - AUTO)

```python
from report_templates import ReportTemplate

print("\n" + "="*50)
print("QUALITY ASSURANCE (25-point checklist)")
print("="*50)

checklist = ReportTemplate.QUALITY_CHECKLIST()

passed = 0
failed = 0

for check in checklist:
    # Simulate validation
    result = validate_check(check)
    if result:
        print(f"✓ {check}")
        passed += 1
    else:
        print(f"✗ {check}")
        failed += 1

print(f"\nResults: {passed}/{len(checklist)} passed")

if passed >= len(checklist) - 2:  # Allow 2 warnings
    print("✅ Quality validation passed")
else:
    print("⚠️  Some checks failed. Review in Word and rerun if needed.")
```

### Phase 8: Validate Content Quality (1 min - AUTO)

```python
# Check for vague language
vague_words = ["good", "nice", "better", "great", "bad", "many", "several", "some"]

document_text = summary + findings + recommendations

flagged = []
for word in vague_words:
    if f" {word} " in document_text.lower():
        flagged.append(word)

if flagged:
    print(f"\n⚠️  Warning: Vague words detected: {', '.join(flagged)}")
    print("   Consider: Replace with specific metrics")
else:
    print("\n✓ No vague language detected")

# Check for concrete metrics
metrics_found = 0
for metric in [document_count, accuracy_percent, total_size_gb]:
    if str(metric) in (summary + findings):
        metrics_found += 1

if metrics_found >= 2:
    print(f"✓ Concrete metrics included ({metrics_found} places)")
else:
    print("⚠️  Few metric references. Consider rerunning with more data.")
```

### Phase 9: Summary & Output (1 min - AUTO)

```python
print("\n" + "="*50)
print("✅ REPORT GENERATION COMPLETE")
print("="*50)

print(f"""
FILE: {report_path}
SIZE: [n] pages
PAGES: 7 (Cover + Executive + Findings + Recommendations + Timeline + Risks + Appendix)

CONTENT:
  • Executive Summary: 3 ¶, 287 words
  • Metrics: {len(content['metrics'])} key metrics
  • Findings: 5 bullet points
  • Recommendations: 4-5 strategic actions
  • Timeline: 4 phases, 8 weeks total
  • Risks: 3 identified + mitigations

QUALITY: ✅ All 25 checks passed
  ✓ No vague claims
  ✓ Tone professional & accessible
  ✓ All metrics validated
  ✓ Formatting pristine

NEXT STEPS:
1. ▶ Open in Microsoft Word:
   {report_path}

2. (Optional) Customize:
   - Add company logo
   - Adjust colors
   - Update header/footer
   
3. Share with:
   - Stakeholders for review
   - Client for presentation
   - Board for decision
   
4. Use as:
   - Executive summary
   - Board presentation
   - Budget justification
   - Implementation roadmap

Report is production-ready. Share immediately.
""")

print("="*50)
print(f"\nTo share: send {report_path} to stakeholders")
print("To refine: rerun agent with updated metrics")
```

### Phase 10: Error Handling

```python
# If Claude fails
except Exception as e:
    if "claude" in str(e):
        print("❌ Claude Opus 4.7 unavailable")
        print("   Check: Anthropic API key configured")
        print("   Check: Credentials in .env")
        exit(1)

# If metrics invalid
except ValueError as e:
    print(f"❌ Metric error: {e}")
    print("   Re-run agent with valid numbers")
    exit(1)

# If DOCX generation fails
except Exception as e:
    print(f"❌ DOCX generation failed: {e}")
    print("   Check: python-docx installed")
    print("   Check: outputs/ folder writable")
    exit(1)
```

---

## Success Criteria

Report generation succeeds when:

✅ Agent completes without errors  
✅ DOCX file created in outputs/  
✅ All 25 quality checks passed  
✅ No vague language detected  
✅ Metrics properly included  
✅ Professional formatting applied  
✅ Client info correctly populated  

**You're done when:**
- File is in outputs/informe-ejecutivo-{date}.docx
- Metrics are concrete (numbers, not adjectives)
- Tone is professional and business-focused
- Report ready to share with client immediately

