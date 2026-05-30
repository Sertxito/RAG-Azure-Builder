# SPEC: Onboarding Wizard

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | onboarding |
| **Propósito** | Guiar al usuario desde cero hasta RAG productivo: entender arquitectura, aprobar costes, desplegar y indexar |
| **Tipo** | Agente (Orquestador principal) |
| **Prioridad** | P0 (Crítica — punto de entrada principal al sistema) |
| **Entrada** | Respuestas del usuario: proyecto, caso de uso, docs, presupuesto, región |
| **Salida** | Sistema RAG completamente operativo con 3 modos de consulta |

---

## 2. Motivación

**Problema:**  
Sin guía, un usuario necesitaría:
- Investigar arquitectura RAG (~2h)
- Comparar precios Azure (~1h)
- Configurar OpenAI + Search + Insights manualmente (~2h)
- Indexar documentos (~1h)
- Configurar modos de consulta (~1h)

Total: ~7 horas de trabajo manual con alto riesgo de errores.

**Valor:**  
- Reduce 7h a 45 minutos automatizados
- Muestra ROI ANTES de gastar dinero
- Previene sobre-dimensionamiento con tier MVP
- El usuario entiende lo que tiene antes de usarlo

**No-objetivos:**  
- NO es un tutorial genérico de Azure
- NO gestiona el ciclo de vida post-despliegue
- NO reemplaza documentación de Azure (complementa con contexto de proyecto)

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada (Entrevista)

```json
{
  "project_name": "string",
  "use_case": "string — 1-2 frases describiendo el problema",
  "doc_count": "number — archivos totales",
  "doc_size": "small|medium|large",
  "query_modes": ["CLI", "chat", "API"],
  "budget_monthly": 2000,
  "region": "eastus"
}
```

**Campos obligatorios:** `project_name`, `use_case`, `doc_count`  
**Campos opcionales:** `doc_size` (auto-detectado), `query_modes` (default: todos), `budget_monthly` (default: 2000), `region` (default: eastus)

### 3.2 Esquema de Salida

```json
{
  "status": "success|cancelled|partial",
  "phases_completed": ["interview", "architecture", "mvp", "upgrades", "approval", "deploy", "index", "ready"],
  "infrastructure": {
    "resource_group": "rag-{project}-rg",
    "monthly_cost_usd": 174,
    "tier": "standard",
    "region": "eastus"
  },
  "index": {
    "documents_indexed": 1950,
    "chunks_total": 1950,
    "index_size_mb": 450
  },
  "query_modes": {
    "cli": "python .github/skills/rag-query-cli/consultar.py",
    "chat": "copilot-cli run .github/agents/rag-chat.agent.md",
    "api": "python .github/skills/rag-api-server/servidor-api.py"
  },
  "summary_file": "outputs/onboarding-summary-{date}.json"
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Onboarding end-to-end < 45 min | Timer total | Cronómetro automático |
| Usuario aprueba antes de desplegar | Confirmación explícita en Fase 6 | Log de aprobación |
| Costes mostrados antes de gastar | Tabla comparativa visible | Fase 4 completada |
| ROI presentado | Comparación 3 escenarios | Fase 5 completada |
| Todos los sistemas operativos al final | Health check pasa | Tests en Fase 9 |
| 3 modos de consulta funcionan | Respuesta exitosa en cada uno | Test query en cada modo |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `USER_CANCELLED` | Usuario dice No en Fase 6 | Guardar config, mostrar cómo reiniciar | No |
| `QUOTA_EXCEEDED` | Sin cuota en región elegida | Ofrecer regiones alternativas (A/B/C) | Sí |
| `INDEX_PARTIAL` | Algunos docs fallan al indexar | Continuar con éxitos, listar fallos | Sí (solo fallos) |
| `DEPLOY_FAILED` | Fallo en azure-setup | Mostrar error, sugerir alternativa | Sí (1 vez) |
| `NO_DOCUMENTS` | Carpeta knowledge/ vacía | Pedir al usuario que añada docs | No (bloqueante) |
| `BUDGET_EXCEEDED` | Config supera presupuesto | Sugerir tier inferior o menos réplicas | No (requiere decisión) |

---

## 6. Puntos de Integración

### Invocado Por
- Usuario directo (punto de entrada principal)
- `copilot-cli run .github/agents/rag-onboarding.agent.md`

### Invoca A
- `rag-validate-deployment` (validación pre-despliegue)
- `rag-azure-setup` (Fase 7: despliegue)
- `rag-indexer-specialist` (Fase 8: indexación)
- `rag-cost-analyst` (cálculos de ROI)
- `rag-architecture-optimizer` (recomendaciones de tier)

### Salida Consumida Por
- `rag-chat` (sistema listo para consultar)
- `rag-cost-scaler` (conoce tier actual para optimizar)
- `rag-generate-report` (métricas para informes)

---

## 7. Restricciones

- NUNCA crear recursos Azure sin aprobación explícita del usuario
- Mostrar SIEMPRE costes estimados antes de cualquier gasto
- El flujo es secuencial — no saltar fases
- Si el usuario cancela, NO dejar recursos huérfanos
- Toda la sesión debe ser reproducible desde el summary JSON

---

## 8. Preguntas Abiertas

- [x] ¿Cuántas fases? → 10 fases (0-10)
- [x] ¿Aprobación antes o después de mostrar ROI? → Después (Fase 6, tras ver ROI en Fase 5)
- [ ] ¿Permitir re-entrada parcial? (retomar desde fase X) → Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
