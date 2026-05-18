---
description: '.github directory: agents, instructions, skills, templates for RAG projects — fully standalone or as part of complete repo'
---

# RAG Framework — `.github/`

**🏛️ GitHub Spec Kit Enterprise Compliant — All 14 Skills + Agents**

Framework reutilizable para proyectos RAG con Azure OpenAI + AI Search. Descárgalo, inicializa, añade tus documentos y funciona.

> ⚠️ Todos los costes en USD. Modelo mínimo: **gpt-4o** (no se usa gpt-4o-mini).
> Disponibilidad de modelos varía por región — se valida automáticamente en el onboarding.

---

## Inicio rápido

```bash
# 1. Instalar dependencias
pip install -r .github/requirements.txt

# 2. Lanzar agente de onboarding (explica arquitectura, costes y ROI ANTES de desplegar)
copilot-cli run .github/agents/rag-onboarding.agent.md
```

---

## Agentes disponibles

| Agente | Cuándo usarlo |
|---|---|
| `rag-onboarding` | **Punto de entrada principal** — interview, arquitectura, costes, ROI, deploy |
| `rag-validate-deployment` | Validar presupuesto y disponibilidad de modelos por región |
| `rag-azure-setup` | Desplegar infraestructura Azure (OpenAI + Search + AppInsights) |
| `rag-indexer-specialist` | Indexar documentos de `knowledge/` en Azure Search |
| `rag-sharepoint-setup` | Integrar SharePoint (modo profesional o local) |
| `rag-chat` | Chat conversacional multi-turno sobre tus documentos |
| `rag-generate-report` | Generar informe ejecutivo profesional (DOCX) |

```bash
copilot-cli run .github/agents/rag-onboarding.agent.md
copilot-cli run .github/agents/rag-validate-deployment.agent.md
copilot-cli run .github/agents/rag-azure-setup.agent.md
copilot-cli run .github/agents/rag-indexer-specialist.agent.md
copilot-cli run .github/agents/rag-sharepoint-setup.agent.md
copilot-cli run .github/agents/rag-chat.agent.md
copilot-cli run .github/agents/rag-generate-report.agent.md
```

---

## 🤖 Estrategia de Modelos (Claude)

**TIER 1 - Claude Opus 4.7** (Máxima calidad para decisiones críticas):

```
rag-generate-report      → Reportes ejecutivos (narrativa compelling)
rag-chat                 → Chat inteligente (razonamiento multi-turn)
rag-validate-deployment  → Análisis costes & arquitectura
```

**TIER 2 - Claude Haiku 4.5** (Eficiente para scaffolding & orquestación):

```
rag-azure-setup          → Generador Bicep/IaC
rag-onboarding → Orquestador del wizard
rag-sharepoint-setup     → Setup OAuth & integración
rag-indexer-specialist   → Análisis de documentos
```

---

## Skills disponibles

```bash
python .github/skills/rag-query-cli/consultar.py "tu pregunta"
python .github/skills/rag-indexer/indexar.py
python .github/skills/rag-diagnostics/estado-sistema.py
python .github/skills/rag-api-server/servidor-api.py --port 8000

# Validar región + coste antes de desplegar
python .github/skills/rag-cost-analyst/cost_analyzer.py
```

| Skill | Propósito |
|---|---|
| `rag-query-cli/` | Búsqueda interactiva por CLI |
| `rag-indexer/` | Indexar documentos de `knowledge/` |
| `rag-diagnostics/` | Estado del sistema y monitoreo |
| `rag-api-server/` | API REST para integrar con apps |
| `rag-cost-analyst/` | Validar costes + disponibilidad de modelos por región |
| `rag-cost-scaler/` | **[NEW]** Escalar/reducir configuración entre minimal/standard/premium + alertas automáticas |
| `rag-deployment-templates/` | Bicep para infraestructura Azure (gpt-4o + embeddings) |
| `rag-agent-instrumentation/` | Métricas y Application Insights |
| `rag-sharepoint-connector/` | Integración SharePoint (profesional/local) |
| `rag-report-generator/` | Informes ejecutivos con Claude Opus 4.7 |
| `rag-architecture-optimizer/` | Validar arquitectura y tamaño de servicios |
| `rag-orchestration/` | Orquestador de 8 fases |
| `rag-qa-engine/` | Motor de Q&A conversacional |
| `rag-storage-connector/` | Credenciales Azure Blob Storage (PowerShell) |
| `rag-validator/` | Validar cumplimiento Microsoft guidelines |

---

## 💰 Gestión de Costos - RAG Cost Scaler

Después de desplegar tu RAG, puedes escalar o reducir costos dinámicamente sin downtime:

```powershell
cd .github/skills/rag-cost-scaler/

# Ver opciones disponibles (minimal €30, standard €75, premium €250)
.\cost-scaler.ps1 -Action ListTiers

# Ver configuración actual
.\cost-scaler.ps1 -Action ShowCurrent

# Cambiar a Standard (para producción con más volumen)
.\cost-scaler.ps1 -Action ChangeTo -Tier standard

# Crear alertas de presupuesto
.\cost-scaler.ps1 -Action CreateAlerts -Budget 75
```

**3 Tiers Predefinidos:**
- 🟢 **Minimal** (€30/mes) — Azure Search Basic, 30 días logs → Dev/testing
- 🟡 **Standard** (€75/mes) — Azure Search Standard, 90 días logs → Producción
- 🔴 **Premium** (€250/mes) — Search Premium, 1 año logs → Máxima escala

El skill automáticamente:
- ✅ Detecta configuración actual
- ✅ Calcula impacto de costos
- ✅ Aplica cambios en Azure (eliminación/creación de servicios)
- ✅ Configura alertas de presupuesto
- ✅ Maneja retenciones de logs

---

## Arquitectura

```text
Usuario
  │
  └── copilot-cli run .github/agents/rag-onboarding.agent.md
       │
       │  Phase 0-6: Educación (arquitectura, costes, ROI, aprobación)
       │  Phase 7:   Llama a rag-azure-setup → Bicep → Azure
       │  Phase 8:   Llama a rag-indexer-specialist → knowledge/ → Search
       │  Phase 9:   Listo para consultar
       │
       ├── agents/               → 7 agentes (.agent.md)
       ├── instructions/         → Guías de implementación
       └── skills/               → 14 módulos Python/PowerShell
           │
           └── knowledge/        → Tus documentos (PDFs, Word, SQL, PPTX...)
                 ↓ indexar (text-embedding-3-small)
               Azure AI Search   → Búsqueda híbrida (keyword + semántica + vector)
                 ↓ recuperar
               Azure OpenAI      → gpt-4o (mínimo) · pay-per-token · ~$0.01/query
```

---

## Estructura de ficheros

```text
.github/
├── requirements.txt        ← Dependencias Python
├── README.md               ← Estás aquí
├── agents/                 ← 7 agentes + TEMPLATE
├── instructions/           ← Guías de implementación por agente
└── skills/                 ← 14 módulos reutilizables
    └── cada skill con SKILL.md + código (Python o PowerShell)

rag-{proyecto}/             ← Proyecto RAG autónomo (hermano de .github/)
├── .env                    ← Credenciales Azure (gitignored)
└── knowledge/              ← Tus documentos
    ├── pdfs/
    ├── procedimientos/
    ├── codigo/
    └── presentaciones/
```

---

## 🏛️ GitHub Spec Kit Enterprise Compliance

**All 14 Skills + 3 Agents fully documented — 100% Spec Kit Compliant**

### Spec Coverage Matrix

| Skill | Spec File | Status | Sections | Error Codes |
|---|---|---|---|---|
| **TIER 1: CRITICAL** |
| rag-cost-scaler | ✅ | FULL | 8 | 8 (+ 7 tests) |
| rag-azure-setup | ✅ | FULL | 8 | 8 |
| rag-indexer | ✅ | FULL | 9 | 8 |
| rag-orchestration | ✅ | FULL | 5 | Variable |
| **TIER 2: IMPORTANT** |
| rag-query-cli | ✅ | COMPACT | 5 | 3 |
| rag-diagnostics | ✅ | COMPACT | 5 | 3 |
| rag-api-server | ✅ | COMPACT | 5 | 3 |
| rag-cost-analyst | ✅ | COMPACT | 5 | 3 |
| rag-agent-instrumentation | ✅ | COMPACT | 5 | 2 |
| rag-sharepoint-connector | ✅ | COMPACT | 5 | 3 |
| rag-report-generator | ✅ | COMPACT | 5 | 2 |
| rag-architecture-optimizer | ✅ | COMPACT | 5 | 2 |
| rag-qa-engine | ✅ | COMPACT | 5 | 2 |
| rag-storage-connector | ✅ | COMPACT | 5 | 2 |
| rag-validator | ✅ | COMPACT | 5 | 2 |
| **AGENTS** |
| rag-cost-scaler | ✅ | FULL | 6 phases | Integrated |
| rag-validate-deployment | ✅ | FULL | 5 | 6 |
| rag-onboarding | ✅ | UPDATED | 10 phases | Phase 10: Cost Optimization |

**Coverage: 18/18 specs ✅ (100%)**

Each specification includes:
- ✅ Overview (name, purpose, tier, responsibility)
- ✅ Input/Output contracts (JSON schemas)
- ✅ Success criteria (functional + non-functional)
- ✅ Error handling table (2-8 error codes + recovery)
- ✅ Integration points (Called by / Calls / Output consumed)
- ✅ Release gates (pre-production validation)
- ✅ Testing strategy (unit / integration / manual)
- ✅ Version control (v1.0.0)

**Automated Testing:**
```bash
cd .github/skills/rag-cost-scaler/tests/
python test_release_gates.py
# Result: ✅ 7/7 TESTS PASSED
```

### Spec Kit Files Location

- Each skill: `.github/skills/{skill-name}/{skill-name}.spec.md`
- Agents: `.github/agents/{agent-name}.spec.md`
- Master reference: This README section

---

## Standards Compliance

✅ **RAG Setup Standards** (Observability, Error Handling, Logging)  
✅ **GitHub Spec Kit Enterprise** (Input/Output contracts, Release gates)  
✅ **Microsoft Guidelines** (Security, compliance, best practices)  
✅ **Avanade Enterprise** (Cost tracking, multi-region support)
