---
name: 'RAG: Executive Report Generator'
description: 'Generate professional executive reports in DOCX format using Claude Opus 4.7. Creates compelling, high-impact narratives with quantified benefits and strategic recommendations. Perfect for client presentations and stakeholder communication.'
model: 'claude-opus-4.7'
tools: true
skills: ['rag-report-generator', 'rag-agent-instrumentation']
---

**RAG Reference:** [Technical Writing for Executives](https://hbr.org/how-to-guides)

## Purpose

**Generate the document you'll defend to your client** — a professional DOCX report that presents RAG implementation with:

✅ Professional formatting (corporate design, branded colors)  
✅ AI-powered narrative (Claude Opus 4.7 generated content, not templates)  
✅ Quantified impact (numbers, metrics, ROI)  
✅ Strategic recommendations (actionable, prioritized, costed)  
✅ Executive tone (accessible to C-suite, credible with technologists)

---

## When to Use

- `Generate executive report`
- `Create presentation document`
- `Make final report for client`
- `Summarize RAG implementation`
- `Justify investment to stakeholders`
- `Document project completion`

---

## Prerequisites

✅ RAG system deployed and tested  
✅ Metrics collected (document count, accuracy, performance)  
✅ Azure OpenAI/Anthropic available (Claude Opus 4.7 model)  
✅ Client name & project context defined  
✅ Recommendations validated with stakeholders (optional but recommended)

---

## Expected Duration

- **Quick** (template-based): 5 minutes
- **Full** (AI-generated, curated): 15-20 minutes
- **Premium** (reviewed, refined): 30-45 minutes

---

## What This Agent Does

### Phase 1: Gather Information (2 min - INTERACTIVE)

```
Questions:
  1. Report type? (RAG Implementation / Document Analysis / Cost Assessment)
  2. Client name?
  3. Project name?
  4. Your name (author)?
  
  5. How many documents indexed?
  6. Total document size (GB)?
  7. System accuracy/precision (%)?
  8. Key benefit (e.g., "search speed improved from 15min to 30sec")?
  
  9. Main challenge before RAG?
 10. Recommended next step?
```

### Phase 2: Collect Metrics (1 min - AUTO/OPTIONAL)

Optionally pull metrics from:
- Azure Search (document count, index size)
- Application Insights (query performance, uptime)
- Cost Analyzer (estimated ROI)

Or use manually provided metrics.

### Phase 3: Generate Content with Claude Opus 4.7 (3 min - AUTO)

Using Claude Opus 4.7 (proven in production), generate:

**Executive Summary**
- AI-written (not template)
- 2-3 paragraphs, 200-300 words
- Includes: context, results, next steps
- Tone: professional, accessible, data-driven

**Findings Section**
- Synthesizes provided metrics
- Highlights key achievements
- 3-5 structured bullet points

**Recommendations**
- 4-5 strategic actions
- Each with: description, benefit, timeline, priority
- Realistic investment estimates

### Phase 4: Create Professional DOCX (2 min - AUTO)

- Cover page (client, date, project name)
- Formatted title & subtitle
- Metadata table
- Page breaks
- Professional typography (colors, sizes)
- Highlighted sections
- Tables for metrics & timeline

### Phase 5: Quality Check (2 min - AUTO)

Validate report against 25-point checklist:
- ☑ No vague claims
- ☑ All statements backed by data
- ☑ Concrete numbers throughout
- ☑ Tone: professional but accessible
- ☑ No spelling/punctuation errors
- ☑ Format consistent
- ☑ All sections present

### Phase 6: Output & Next Steps (1 min - AUTO)

Save report to `outputs/informe-ejecutivo-{date}.docx`

Print:
```
✅ Report Generated

File: outputs/informe-ejecutivo-20260514.docx
Pages: [n]
Client: [name]
Metrics: [n] recommendations, [document count] docs, [ROI]

Next Steps:
1. Review report in Word
2. Customize logo/colors (optional)
3. Share with stakeholders
4. Address feedback (rerun if needed)
5. Present to client
```

---

## Output

### Success Output

```
✅ EXECUTIVE REPORT GENERATED

File: outputs/informe-ejecutivo-20260514.docx
Size: [n] pages
Client: MENSADEF
Project: Búsqueda Inteligente

Content:
  • Executive Summary: 3 paragraphs, 287 words
  • Metrics: 2,345 docs, 97% accuracy, 30-sec search
  • Findings: 5 key achievements
  • Recommendations: 4 strategic actions (1 High, 2 Med, 1 Low)
  • Timeline: 4 phases, 8 weeks total
  • Risks: 3 identified + mitigations

Quality: ✅ All 25 checks passed
  ✓ No vague claims
  ✓ Tone professional & accessible
  ✓ All metrics validated
  ✓ ROI: $120K/year
  ✓ Format pristine

NEXT STEPS:
1. Open report in Microsoft Word
2. Customize: logo, colors, header/footer (optional)
3. Share with review team or stakeholder
4. Use in: board meeting, client pitch, executive summary
5. Refinements: Run agent again with feedback

Report is production-ready and can be shared immediately.
```

---

## Quality Assurance

Every report passes:

### ✅ Content Validation
- No vague statements ("good", "nice", "better")
- All claims backed by metrics
- ≥ 3 quantified benefits
- Executive summary < 300 words
- Recommendations actionable (not generic)

### ✅ Tone Validation
- Professional but accessible
- Business impact emphasized (not tech details)
- Concrete numbers (2,345 not "many")
- Active voice (not passive)
- Persuasive without overpromising

### ✅ Format Validation
- Professional design (corporate colors, fonts)
- Proper typography (sizes, spacing)
- All sections present
- No broken links or references
- Spelling & grammar perfect

### ✅ RAG-Specific Checks
- Document count highlighted
- Performance improvement quantified
- Why Azure (not generic cloud)
- Security/compliance mentioned
- Clear ROI or business case

---

## Customization

After generation, you can customize:

**Easy (in Word):**
- Logo (Header & Footer)
- Colors (if branded templates used)
- Company name/footer
- Font preferences

**Advanced (rerun agent):**
- Change client name
- Update metrics
- Adjust tone (more/less technical)
- Add/remove sections
- Different report type

---

## Common Questions

**Q: Can I modify the generated report?**
A: Yes! It's a standard DOCX. Edit in Word, adjust content, customize branding.

**Q: How long is the report?**
A: Typically 5-8 pages (cover + 7 content sections). Can expand with appendices.

**Q: Can I add company logo?**
A: Yes. After generation, open in Word and add to header/footer or cover page.

**Q: Is the content accurate?**
A: Claude Opus 4.7 generated content is validated against your provided metrics. If metrics are wrong, regenerate with correct data.

**Q: Can I use for different clients?**
A: Yes. Just rerun agent with different client name, project name, and metrics.

**Q: How often should I regenerate?**
A: Once at project completion. If metrics change significantly, regenerate with new data.

---

## Examples

See [rag-report-generator/SKILL.md](../rag-report-generator/SKILL.md) for:
- Good vs. Bad executive summary examples
- Professional tone guidelines
- Quality checklist (25 items)
- Recommendation structure examples
- Metrics to always include

---

## Related Skills

- **rag-report-generator** - Core generation engine
- **rag-diagnostics** - Metrics collection
- **rag-cost-analyst** - ROI calculation
- **rag-agent-instrumentation** - Logging & tracking
