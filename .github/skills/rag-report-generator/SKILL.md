---
name: rag-report-generator
description: "Professional executive report generation using Claude Opus 4.7. Generates high-quality DOCX reports with professional formatting, compelling narratives, and quantified impact metrics. Perfect for client presentations and stakeholder communication."
version: "1.0.0"
author: "RAG Framework"
tags: ["reporting", "executive-summary", "docx", "claude", "professional"]
---

# RAG: Professional Report Generator

**Executive Report Generation with AI-Powered Content**

Creates professional, high-impact executive reports that defend your RAG implementation to clients and stakeholders.

---

## 🎯 Purpose

This skill **generates document final que defiendes ante el cliente** — a professional DOCX report that presents RAG implementation results with:

✅ **Professional formatting** — Corporate design, proper typography, branded colors  
✅ **AI-powered content** — Claude Opus 4.7 generates compelling narratives and data synthesis  
✅ **Quantified impact** — Numbers, metrics, ROI (not vague promises)  
✅ **Strategic recommendations** — Actionable next steps with timeline and investment  
✅ **Executive tone** — Accessible to C-suite, yet credible with technical stakeholders  

---

## 📋 Features

✨ **Content Generation**
- Executive summary (2-3 paragraphs, AI-written)
- Findings section (synthesized from data)
- Recommendations (strategic, prioritized, costed)
- Implementation timeline (4 phases + details)
- Risk mitigation strategies

✨ **Professional Formatting**
- Corporate design with branded colors
- Table of contents & page breaks
- Professional fonts (Calibri, sizing)
- Highlighted information boxes
- Proper margins & spacing
- Company logo support (optional)

✨ **Quality Assurance**
- 25-point quality checklist
- Tone validation (professional, accessible)
- Metric verification (no vague claims)
- Grammar & spelling checks
- Format consistency

✨ **Integrations**
- **Claude Opus 4.7** for high-quality content (strategic reasoning)
- **Azure Search** metrics (document count, index size)
- **Azure OpenAI** data (model deployment, token usage)
- **Application Insights** (performance metrics)
- **Cost Analyzer** (ROI calculations)

---

## 🚀 Quick Start

### Prerequisites

```bash
pip install python-docx openai
```

### Generate Report (Simple)

```python
from report_generator import ExecutiveReportGenerator, ReportMetadata, ReportType
from pathlib import Path

# Initialize
gen = ExecutiveReportGenerator()

# Metadata
metadata = ReportMetadata(
    title="Informe Ejecutivo: Búsqueda Inteligente",
    client_name="MENSADEF",
    project_name="RAG Implementation",
    report_type=ReportType.RAG_IMPLEMENTATION,
)

# Content
content = {
    "executive_summary": "AI-generated summary here...",
    "metrics": {
        "Documentos": "2,345",
        "Tamaño": "15.3 GB",
        "Precision": "97%",
    },
    "findings_text": "AI-generated findings...",
    "recommendations_text": "AI-generated recommendations...",
}

# Generate
output = gen.generate_report(metadata, content, Path("outputs/informe.docx"))
print(f"✅ Report: {output}")
```

### Generate Report (Complete with AI)

```python
gen = ExecutiveReportGenerator()

# Generate content using Claude Opus 4.7
summary = gen.generate_executive_summary(
    project_name="RAG MENSADEF",
    document_count=2345,
    total_size_gb=15.3,
    key_findings=["High-quality docs", "Well-structured", "Automation opportunity"],
    recommendations=["Hybrid search", "SharePoint integration"],
)

findings = gen.generate_findings_section({
    "document_count": 2345,
    "total_size_gb": 15.3,
    "quality": "High",
})

recommendations = gen.generate_recommendations(
    context="RAG project with 2345 documents"
)

# Assemble report
content = {
    "executive_summary": summary,
    "findings_text": findings,
    "recommendations_text": recommendations,
    "metrics": {...},
    "timeline": {...},
}

report_path = gen.generate_report(metadata, content, Path("outputs/informe.docx"))
```

---

## 📐 Quality Guidelines

### Executive Summary

**GOLDEN RULES:**
- ✅ **2-3 paragraphs MAXIMUM** (200-300 words)
- ✅ **Concrete numbers** (2,345 docs, not "many")
- ✅ **One value proposition per sentence**
- ✅ **Active verbs** (not passive)
- ✅ **Business impact first, technology second**

**STRUCTURE:**

```
Párrafo 1: Contexto (Qué → Cuándo)
"Se ha implementado un sistema de búsqueda inteligente sobre 2,345 documentos
de MENSADEF, integrando procedimientos, legislación y análisis técnico."

Párrafo 2: Resultados (Cuánto mejora)
"Reduce tiempo de búsqueda de 15 minutos a 30 segundos, beneficiando
a 200+ usuarios. Precisión: 97% en primeros resultados."

Párrafo 3: Next Steps (Qué sigue)
"Sistema listo para producción Q2. Se recomienda: (1) Activar en sprint,
(2) Integrar SharePoint Q3, (3) Análisis en Q4."
```

### Recommendations

**FORMAT:**

```
[#]. [Action Title]

Descripción: [WHAT - 1-2 sentences]
Beneficio: [IMPACT - with numbers]
Implementación: [TIMELINE - short/medium/long]
Inversión: [COST - or "$0 (existing licenses)"]
Prioridad: [HIGH/MEDIUM/LOW]
```

**EXAMPLE (Good):**

```
1. Integrar SharePoint con búsqueda

Descripción: Conectar automáticamente nuevos documentos de SharePoint
a la búsqueda inteligente, eliminando uploads manuales.

Beneficio: Reduce tiempo de indexación de 1 hora a 10 minutos.
Garantiza documentos siempre actualizados.

Implementación: 2-3 semanas (corto plazo)

Inversión: $0 (aprovecha licencias existentes)

Prioridad: Alta
```

**EXAMPLE (Bad - avoid):**

```
"Mejorar el sistema" ← Vague, not actionable
"Considerar opciones futuras" ← Not concrete
"Optimizar según necesidades" ← Too generic
```

### Tone & Language

| Good | Avoid |
|------|-------|
| "2,345 documentos" | "Muchos documentos" |
| "Reduce tiempo de búsqueda de 15 min a 30 seg" | "Búsqueda más rápida" |
| "97% de precisión en primer resultado" | "Resultados precisos" |
| "Beneficia a 200+ usuarios" | "Será útil para usuarios" |
| "ROI: 120% en año 1" | "Buen retorno de inversión" |
| "Máximo 4 líneas por párrafo" | Párrafos largos de 10+ líneas |
| "Verbos activos: Implementamos, Reducimos" | Pasiva: "Fue implementado, Fue reducido" |

### Metrics to Always Include

- **Document count:** "2,345 documentos indexados"
- **Performance:** "Búsqueda: 15 min → 30 seg"
- **Accuracy:** "97% de precisión en primer resultado"
- **Users impacted:** "200+ usuarios beneficiados"
- **System reliability:** "99.9% disponibilidad"
- **ROI:** "$120K ahorros anuales" (if available)
- **Timeline:** "8 semanas de implementación"

---

## 🏆 Quality Checklist

Before finalizing report, verify:

### ✅ Content Quality
- [ ] Every statement backed by data
- [ ] No vague adjectives (good, nice, better)
- [ ] Concrete numbers (not "many", "several")
- [ ] Executive summary < 300 words
- [ ] ≥ 3 quantified benefits
- [ ] Recommendations are actionable

### ✅ Tone & Language
- [ ] Professional but accessible
- [ ] No technical jargon (or explained)
- [ ] Paragraphs < 4 lines
- [ ] Active verbs (no passive voice)
- [ ] Bullet points parallel structure

### ✅ Structure
- [ ] Cover page with metadata
- [ ] Table of contents
- [ ] Clear intro with context
- [ ] Transitions between sections
- [ ] Strong conclusion with next steps
- [ ] ≥ 1 diagram or table

### ✅ Professional
- [ ] 0 spelling errors
- [ ] 0 punctuation errors
- [ ] Consistent formatting (fonts, sizes)
- [ ] Tables properly formatted
- [ ] Page breaks where needed

### ✅ RAG-Specific
- [ ] Document count mentioned
- [ ] Performance improvement (time/accuracy)
- [ ] Why Azure (not generic cloud)
- [ ] Security/compliance statement
- [ ] Clear ROI or business impact

---

## 📊 Report Templates

### RAG Implementation Report

**Sections:**
1. Executive Summary (2-3 ¶)
2. Situation Analysis (5 bullets)
3. Proposed Solution (conceptual)
4. Quantified Benefits (≥3)
5. Recommendations (4-5)
6. Implementation Timeline (4 phases)
7. Risk Mitigation (risks + solutions)
8. Appendices (technical details)

**Timeline Template:**
- Phase 1: Preparation (1-2 weeks) - Setup, training
- Phase 2: Implementation (2-4 weeks) - Indexing, config
- Phase 3: Validation (1-2 weeks) - UAT, adjustments
- Phase 4: Production (1 week) - Go-live, support

**Typical Duration:** 4-8 weeks

### Document Analysis Report

For large document corpus analysis before RAG.

### Cost Assessment Report

For budget justification and ROI calculation.

### Project Readiness Report

For pre-deployment validation.

---

## 🤖 AI Model Selection

**CRITICAL: Always use Claude Opus 4.7 for reports**

Why NOT lower-tier models:
- ❌ Less nuanced understanding of business impact
- ❌ Can generate vague statements
- ❌ Lower coherence for long documents
- ❌ May miss important context

Why Claude Opus 4.7:
- ✅ Superior reasoning for strategic recommendations
- ✅ Exceptional narrative quality and tone (proven in MENSADEF)
- ✅ Deep understanding of business context
- ✅ Generates more compelling, credible content
- ✅ Better structured outputs for executive audience

**Config:**
```python
self.model = "claude-opus-4.7"  # Always, never downgrade to lower tier
temperature = 0.7  # Balanced: structured yet creative
max_tokens = 500-800  # Enough for quality, not verbose
```

---

## 📝 Examples

### Good Example (MENSADEF Real)

```
Se ha implementado un sistema inteligente de búsqueda sobre 2,345 documentos
internos de MENSADEF, que cubre procedimientos, legislación, casos de uso y
análisis técnico. Utilizando Azure OpenAI y Azure Search, el sistema permite
búsqueda semántica instantánea que reduce el tiempo de consulta de 15 minutos
a 30 segundos, beneficiando a más de 200 usuarios.

Los resultados iniciales muestran que el 94% de las búsquedas devuelven el
documento correcto en el primer resultado. Se han validado 500+ casos de uso
reales, con una precisión del 97%. El sistema está listo para producción y
puede escalarse a 5,000+ documentos sin cambios arquitectónicos.

Se recomienda: (1) activar búsqueda en producción en la próxima sprint,
(2) integrar SharePoint en Q3 para documentos corporativos, (3) expandir a
análisis de tendencias en Q4. La inversión inicial de $15K generará $120K en
ahorros anuales por reducción de tiempo de búsqueda.
```

**Why it works:**
- ✅ Specific numbers (2,345, 15→30 sec, 200 users, 94%, 97%, 500+)
- ✅ Business value highlighted (time savings, user impact)
- ✅ Validation shown (cases tested, precision measured)
- ✅ Concrete next steps (sprint, Q3, Q4)
- ✅ ROI quantified ($15K invest, $120K savings)
- ✅ Professional tone, no hyperbole

---

## 🔗 Integration with Agents

### Used by

- **rag-onboarding.agent.md** - Phase 8 (generate final report)
- **rag-report-specialist.agent.md** (dedicated report agent)

### Calls

- `report-generator.py` (main module)
- `report-templates.py` (quality guidelines)
- Azure OpenAI / Anthropic SDK (Claude Opus 4.7 content generation)
- Azure Search API (metrics, index stats)
- python-docx (DOCX generation)

---

## 🛠️ Advanced: Custom Templates

Create custom report for specific clients:

```python
from report_templates import ReportTemplate, ContentGuidelines

# Get template
template = ReportTemplate.RAG_IMPLEMENTATION()

# Customize sections
for section in template["sections"]:
    if section["name"] == "Recomendaciones":
        section["guidelines"] += "\n• Extra: Menciona cumplimiento GDPR"

# Use guidelines
guidelines = ContentGuidelines.RECOMMENDATIONS
print(guidelines)
```

---

## 🚨 Common Mistakes

| Mistake | Why Bad | Fix |
|---------|---------|-----|
| No numbers | Sounds like marketing, not credible | Add metrics: "2,345 docs", "97% accuracy" |
| Passive voice | Weak, unclear responsibility | Use active: "We implemented" not "Was implemented" |
| Vague benefits | Reader doesn't know actual value | Quantify: "saves 120K/year" not "saves money" |
| Too technical | Loses executive audience | Explain: "semantic search (find docs by meaning)" |
| Long paragraphs | Hard to follow, loses emphasis | Max 4 lines, one idea per paragraph |
| No next steps | Leaves reader hanging | List 3-5 concrete actions with timeline |
| Single recommendation | Seems incomplete | 4-5 recommendations (prioritized) |
| No timeline | Sounds unrealistic | Break into phases with realistic durations |

---

## 📚 References

- [Executive Summary Best Practices](https://hbr.org/how-to-guides)
- [Technical Writing for Non-Technical Audiences](https://www.coursera.org/)
- [Azure Best Practices Documentation](https://learn.microsoft.com/)

---

## ✅ Success Criteria

Report generation succeeds when:
- [ ] Client reads first page and understands value
- [ ] CFO finds ROI justification in Page 2
- [ ] CTO finds technical credibility in Appendix
- [ ] Recommendation chosen within 1 week
- [ ] Project greenlit (most common result)
- [ ] Stakeholders cite metrics in meetings

**You're done when client says:** *"This is exactly what we needed to justify this investment."*

