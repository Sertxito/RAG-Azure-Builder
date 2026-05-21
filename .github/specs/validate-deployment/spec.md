# SPEC: Validate Deployment

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | validate-deployment |
| **Propósito** | Validar costes, disponibilidad regional y arquitectura antes de desplegar infraestructura RAG en Azure |
| **Tipo** | Skill (Validación pre-despliegue) |
| **Prioridad** | P0 (Crítica — previene errores costosos) |
| **Entrada** | Configuración: región, modelos, tier, presupuesto, subscription |
| **Salida** | JSON con resultados de validación, desglose de costes, recomendaciones |

---

## 2. Motivación

**Problema:**  
Desplegar infraestructura RAG en Azure sin validación previa puede resultar en sorpresas de +$1K/mes por tiers de Search sobre-provisionados, retención excesiva de AppInsights, o modelos OpenAI en el tier equivocado.

**Valor:**  
- Previene sobrecostes antes de crear cualquier recurso
- Ahorra horas de investigación manual de precios
- Identifica limitaciones de región antes de que falle el despliegue
- Sugiere alternativas optimizadas automáticamente

**No-objetivos:**  
- NO despliega ningún recurso (validación solo lectura)
- NO gestiona despliegues existentes
- NO reemplaza Azure Cost Management para monitorización continua

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "action": "validate|compare|recommend",
  "region": "eastus",
  "models": ["gpt-4o", "text-embedding-3-small"],
  "search_sku": "standard",
  "search_replicas": 1,
  "logs_retention_days": 90,
  "documents_count": 5000,
  "estimated_queries_monthly": 1000,
  "budget_usd": 2000,
  "subscription_id": "optional-subscription-id"
}
```

**Campos obligatorios:**
- `action`: Uno de {validate, compare, recommend}
- `region`: Identificador de región Azure
- `models`: Lista de nombres de modelo Azure OpenAI

**Campos opcionales:**
- `search_sku`: Default `standard`
- `search_replicas`: Default `1`
- `logs_retention_days`: Default `90`
- `documents_count`: Default `5000`
- `estimated_queries_monthly`: Default `1000`
- `budget_usd`: Default `2000`
- `subscription_id`: Para verificar cuota (se omite si ausente)

### 3.2 Esquema de Salida

```json
{
  "timestamp": "ISO-8601",
  "action": "validate",
  "status": "success|warning|error",
  "duration_seconds": 5,
  "result": {
    "region": "eastus",
    "validation": {
      "region_valid": true,
      "models_available": {"gpt-4o": true},
      "quota_sufficient": true,
      "budget_ok": true,
      "architecture_optimized": true
    },
    "cost_breakdown": {
      "monthly_infrastructure": {"openai_s0": 10, "search_standard_1replica": 295, "total": 355},
      "monthly_inference_estimate": {"queries": 1000, "avg_cost_per_query": 0.025, "total": 25},
      "monthly_total_usd": 380,
      "currency": "USD",
      "confidence_pct": 85
    },
    "recommendations": [
      {"issue": "...", "current": "...", "recommendation": "...", "action": "PROCEED|WARN|BLOCK"}
    ],
    "alternative_regions": [
      {"region": "westus2", "models_available": [], "monthly_cost_usd": 385, "latency_ms": 15}
    ],
    "quota_check": {
      "subscription": "...",
      "quota_available": {},
      "quota_sufficient": true
    }
  },
  "error": null,
  "metadata": {
    "pricing_date": "ISO-8601",
    "pricing_source": "azure.microsoft.com/pricing",
    "validation_method": "Cost Management API + Resource Graph"
  }
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Validación de región | Verifica 3 servicios (OpenAI, Search, Insights) disponibles | Query SKU availability API |
| Disponibilidad de modelos | Verifica que los modelos existen en la región objetivo | Listar modelos desplegables por región |
| Precisión de costes | ± 5% respecto a precios reales de Azure | Comparar vs Cost Management API |
| Verificación de cuota | Detecta cuotas insuficientes | Consultar cuotas de subscription |
| Comparación con presupuesto | Señala si estimado > budget | Validar que campo action es BLOCK/WARN |
| Recomendaciones | Sugiere alternativas de tier/región | Output contiene ≥1 recomendación |
| Sin efectos secundarios | Validación nunca crea/modifica recursos Azure | Audit log muestra cero escrituras |
| Salida JSON | Válida, parseable contra schema | Validación de schema pasa |
| Tiempo de respuesta | < 5 segundos | Timer en logs estructurados |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `REGION_NOT_SUPPORTED` | La región no tiene los servicios requeridos | Sugerir regiones alternativas | No |
| `MODEL_NOT_AVAILABLE` | Modelo específico no desplegado en la región | Sugerir modelos/regiones alternativas | No |
| `QUOTA_INSUFFICIENT` | Cuota de subscription por debajo de requisitos | Sugerir solicitar aumento + mostrar link | No |
| `BUDGET_EXCEEDED` | Configuración supera presupuesto declarado | Sugerir opciones de downgrade con costes | No |
| `PRICING_API_ERROR` | No se puede obtener pricing actual | Usar tarifas cacheadas/estimadas, señalar confianza | Sí |
| `QUOTA_API_ERROR` | No se puede verificar cuota de subscription | Continuar con warning, omitir sección cuota | Sí |
| `INVALID_CONFIG` | Combinación SKU/tier inválida | Sugerir combinaciones válidas | No |

---

## 6. Puntos de Integración

### Invocado por
- `rag-onboarding.agent.md` — Fases 4-5 (antes de aprobación de despliegue)
- `rag-validate-deployment.agent.md` — Invocación directa del usuario
- Checks manuales pre-despliegue

### Invoca
- Azure Pricing API (datos de coste)
- Azure Resource Graph (disponibilidad SKU/región)
- Azure Quotas API (límites de subscription)

### Salida consumida por
- `rag-onboarding.agent.md` — Muestra resumen de costes para aprobación
- Gates de decisión — El usuario decide si proceder

---

## 7. Restricciones

- Debe cumplir constitución §1 (Cost Awareness First)
- Debe cumplir constitución §3 (Observabilidad)
- Debe cumplir constitución §4 (Nunca Fallar Silenciosamente)
- Cero operaciones de escritura en Azure — validación solo lectura
- Datos de precios deben ser actualizables (no hardcodeados indefinidamente)

---

## 8. Supuestos de Precios

Actualizar trimestralmente:

```
Azure OpenAI:
  gpt-4o: $2.50/1M input + $10/1M output
  text-embedding-3-small: $0.02/1M tokens

Azure AI Search:
  Basic: $75/mes (1M docs máx)
  Standard: $295/mes por réplica
  Premium: $1,500/mes por réplica

Application Insights:
  Gratis: 5GB/día, 90 días retención
  Pago: $2.50/GB ingestado
```

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial (migrado de agents/ a specs/) |
| 1.0.1 | 2026-05-21 | Traducido a español para consistencia del repositorio |
