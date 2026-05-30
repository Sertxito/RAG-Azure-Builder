# Constitución RAG Builder

> Principios innegociables para todo desarrollo, despliegue y operación en este proyecto.

**Versión:** 1.0.0  
**Última actualización:** 2026-05-20  
**Proceso de enmienda:** Architecture Decision Record + análisis de impacto + aprobación del equipo.

---

## 1. Conciencia de Costes Primero

- **SIEMPRE** validar costes ANTES de desplegar cualquier recurso Azure.
- Nunca exceder el presupuesto declarado por el usuario sin aprobación explícita.
- Por defecto usar el tier más barato que cumpla los requisitos funcionales.
- Mostrar desglose de costes por componente (infraestructura + estimaciones de inferencia).
- Prevenir sorpresas de $1K+/mes por servicios sobredimensionados.

## 2. Cero Fugas de Credenciales

- Sin claves hardcodeadas, connection strings ni secretos en código o specs.
- Todos los secretos vía `.env` (local) o Key Vault (producción).
- Managed Identity preferido sobre API keys.
- Los ficheros `.env` DEBEN estar en `.gitignore`.

## 3. Observabilidad Obligatoria

Todos los agentes y scripts DEBEN:

- Loguear en `./outputs/rag.log` (local) + Application Insights (remoto).
- Capturar: input de query, respuesta, latencia de búsqueda, tokens, coste por operación.
- Usar logging estructurado con campos `extra={}`.
- Usar `MetricsCollector` del skill `rag-agent-instrumentation`.
- Generar JSON en `outputs/` con timestamp, agente, estado, métricas.

## 4. Gestión de Errores: Nunca Fallar en Silencio

- Toda operación debe tener manejo explícito de errores.
- Sugerir remediación accionable (ej: "¿Cuota de región llena? Prueba westus2").
- Loguear todos los fallos con `exc_info=True`.
- Reintentar solo en errores transitorios (red, throttling de API). Nunca reintentar en errores de validación.

## 5. Spec Antes que Código

- Ninguna feature implementada sin un `spec.md` aprobado.
- El spec define: propósito, contrato I/O, criterios de éxito, manejo de errores.
- El plan define: enfoque técnico, dependencias, riesgos.
- Las tasks definen: pasos de implementación ordenados con criterios de aceptación.
- Cambios de código que violen el spec requieren enmienda del spec primero.

## 6. Principios de Arquitectura RAG

**Referencia:** [RAG en Azure AI Search](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)

- Búsqueda híbrida (keyword + vector) es la estrategia de recuperación por defecto.
- Semantic ranking siempre habilitado para re-scoring.
- Restricciones de tokens: recuperar chunks concisos y relevantes — nunca volcar documentos completos.
- Objetivo de respuesta: 3-5 segundos end-to-end.
- Agentic Retrieval para features nuevas; Classic RAG para paths estables/GA.

## 7. Organización de Documentos

Los usuarios organizan docs ANTES de indexar:

```
knowledge/
├── pdfs/               # PDFs (manuales, políticas, guías)
├── procedimientos/     # Word, Excel, Markdown documentos procedimentales
├── codigo/             # SQL, Python, JS, ficheros de config (YAML, JSON)
└── sharepoint/         # Auto-sincronizado desde SharePoint (si está conectado)
```

## 8. Estándares de Código

| Área | Convención |
|------|-----------|
| Clases | `PascalCase` |
| Funciones | `snake_case` |
| Constantes | `UPPER_CASE` |
| Type hints | Obligatorios en todas las firmas de función |
| Docstrings | Obligatorios en todas las funciones públicas |
| Agent YAML | Debe incluir: `name`, `description`, `model`, `tools` |

## 9. Requisitos de Testing

- Todos los agentes: testear con flag `--verbose`.
- Todos los scripts: incluir precheck `--validate`.
- Queries RAG: ejecutar 3× para validar estabilidad (< 20% variación).
- Ningún PR se mergea sin pasar validación.

## 10. Deployment Gates

Before any deployment:

- [ ] `.env` configured with all Azure credentials
- [ ] Cost validator passed (within budget)
- [ ] Azure resources match spec requirements
- [ ] Azure resources properly tagged (`project`, `environment`, `owner`)
- [ ] RAG index created and populated
- [ ] Validation script passes: `python .github/skills/rag-diagnostics/validate_setup.py --verbose`
- [ ] Metrics output paths exist: `outputs/`

## 11. Agent Architecture

- Agents are **definitions** (`.agent.md`) — they declare capability, not implement it.
- Skills contain **runtime logic** (Python scripts, templates, orchestration).
- Instructions provide **behavioral rules** that apply across agents.
- One agent = one responsibility. Compose via `depends_on`.

---

**Governance:** Any change to this constitution requires:
1. Written rationale documenting the "why"
2. Impact assessment on existing specs and implementations
3. Update to version number (MAJOR for breaking, MINOR for additions, PATCH for clarifications)
