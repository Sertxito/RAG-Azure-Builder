# SPEC: Cost Scaler

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | cost-scaler |
| **Propósito** | Escalar infraestructura RAG entre tiers (mínimo/estándar/premium) con cero downtime y alertas de presupuesto |
| **Tipo** | Agente (Gestión de costes post-despliegue) |
| **Prioridad** | P1 (Alta — optimización continua de costes) |
| **Entrada** | Acción: ver/escalar/alertas + resource group + tier destino |
| **Salida** | Infraestructura escalada + confirmación + nueva estimación de coste |

---

## 2. Motivación

**Problema:**  
Después del despliegue inicial, los costes quedan fijados al tier elegido. Si el uso real es menor al estimado, se desperdicia dinero. Si crece, falta capacidad.

**Valor:**  
- Ahorro de €15-220/mes bajando de tier cuando no se necesita
- Escalado sin downtime cuando crece la demanda
- Alertas automáticas para evitar facturas sorpresa
- Decisiones informadas con dry-run antes de cambios

**No-objetivos:**  
- NO es el despliegue inicial (eso es azure-setup)
- NO gestiona costes a nivel de queries individuales
- NO migra entre regiones (solo escala dentro de la misma)

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "action": "show_current|list_tiers|change_to|create_alerts",
  "resource_group": "rag-defensa-rg",
  "target_tier": "minimal|standard|premium",
  "dry_run": true,
  "budget_threshold_eur": 75,
  "alert_email": "admin@company.com"
}
```

**Campos obligatorios:** `action`, `resource_group`  
**Campos opcionales:** `target_tier` (requerido para change_to), `dry_run` (default: true), `budget_threshold_eur` (requerido para create_alerts), `alert_email` (requerido para create_alerts)

### 3.2 Esquema de Salida

```json
{
  "status": "success|dry_run|error",
  "current_tier": "minimal",
  "current_cost_monthly_eur": 30,
  "action_result": {
    "previous_tier": "minimal",
    "new_tier": "standard",
    "new_cost_monthly_eur": 75,
    "cost_delta_eur": 45,
    "changes_applied": [
      "Deleted rag-defensa-search-basic",
      "Created rag-defensa-search-standard (2 replicas)",
      "Updated Log Analytics retention to 90 days"
    ],
    "reindex_required": true,
    "reindex_status": "completed",
    "downtime_seconds": 0
  },
  "budget_alert": {
    "name": "RAG Cost Scaler Budget",
    "threshold_eur": 75,
    "email": "admin@company.com",
    "status": "active"
  }
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Zero data loss en escalado | 100% docs preservados | Count pre/post = igual |
| Downtime < 10 min | Tiempo de indisponibilidad | Timer durante migración |
| Dry-run no modifica nada | 0 cambios en Azure | Azure Activity Log vacío |
| Coste nuevo refleja tier | Factura siguiente = estimado ±10% | Azure Cost Management |
| Alertas funcionan | Email recibido al superar umbral | Test con threshold bajo |
| Re-indexación automática | Índice operativo post-escalado | Query test post-cambio |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `SEARCH_NOT_FOUND` | Service no existe en RG | Sugerir ejecutar azure-setup primero | No |
| `QUOTA_INSUFFICIENT` | Sin cuota para nuevo SKU | Sugerir región alternativa o solicitar cuota | No |
| `RBAC_DENIED` | Sin permiso Contributor | Instrucciones para solicitar acceso | No |
| `REINDEX_TIMEOUT` | Re-indexación tarda > 30 min | Continuar en background, notificar cuando termine | Sí (auto) |
| `ALERT_EXISTS` | Alerta con mismo nombre ya existe | Preguntar si sobrescribir | No |
| `TIER_SAME` | Ya está en el tier solicitado | Informar, no hacer nada | No |

---

## 6. Puntos de Integración

### Invocado Por
- `rag-onboarding` (Fase 10: optimización post-despliegue)
- Usuario directo (gestión continua de costes)

### Invoca A
- Azure CLI (`az search service`, `az monitor`, `az consumption budget`)
- Azure Resource Manager API
- `rag-indexer-specialist` (re-indexación tras cambio de SKU)
- `rag-agent-instrumentation` (telemetría)

### Salida Consumida Por
- Usuario (decisiones de coste)
- `rag-diagnostics` (monitoriza tier actual)
- Azure Cost Management (alertas)

---

## 7. Restricciones

- SIEMPRE hacer dry-run antes de cambios reales (salvo override explícito)
- Crear backup del índice antes de eliminar servicio antiguo
- Confirmar con usuario antes de aplicar cambios (no auto-escalar)
- Costes mostrados en EUR (facturación Avanade)
- No exponer API keys en logs ni output

---

## 8. Preguntas Abiertas

- [x] ¿Cuántos tiers? → 3 (mínimo, estándar, premium)
- [x] ¿Auto-scaling o manual? → Manual con recomendación (el usuario decide)
- [ ] ¿Soportar scheduling? (bajar a mínimo en noches/fines de semana) → Fase 2
- [ ] ¿Integrar con Azure Advisor recommendations? → Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
