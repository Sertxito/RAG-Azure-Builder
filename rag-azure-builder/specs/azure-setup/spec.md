# SPEC: Azure Setup

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | azure-setup |
| **Propósito** | Desplegar infraestructura Azure completa para RAG: OpenAI, AI Search, Application Insights |
| **Tipo** | Agente (Despliegue de infraestructura) |
| **Prioridad** | P0 (Crítica — sin infra no hay RAG) |
| **Entrada** | Configuración: región, tier, modelos, nombre de proyecto, subscription |
| **Salida** | Recursos Azure creados + archivo .env con credenciales |

---

## 2. Motivación

**Problema:**  
Desplegar manualmente Azure OpenAI + AI Search + App Insights requiere 30+ minutos de clics en portal, conocimiento de Bicep/ARM, y alta probabilidad de errores de configuración.

**Valor:**  
- Reduce despliegue de 30+ min a 10 min automatizados
- Cero errores de configuración (plantillas validadas)
- Credenciales auto-generadas y almacenadas de forma segura
- Infraestructura consistente y reproducible

**No-objetivos:**  
- NO gestiona el ciclo de vida post-despliegue (usar cost-scaler para eso)
- NO indexa documentos (eso es responsabilidad de indexer-specialist)
- NO valida costes pre-despliegue (eso es validate-deployment)

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "project_name": "string — nombre del proyecto (slug-friendly)",
  "region": "string — región Azure (eastus, westus2, northeurope...)",
  "tier": "minimal|standard|premium",
  "models": ["gpt-4o", "text-embedding-3-small"],
  "search_sku": "basic|standard|premium",
  "search_replicas": 1,
  "appinsights_retention_days": 30,
  "subscription_id": "string — optional"
}
```

**Campos obligatorios:** `project_name`, `region`, `tier`  
**Campos opcionales:** `models` (default: gpt-4o + text-embedding-3-small), `search_sku` (derivado de tier), `search_replicas` (derivado de tier), `appinsights_retention_days` (derivado de tier), `subscription_id`

### 3.2 Esquema de Salida

```json
{
  "status": "success|error",
  "resource_group": "rag-{project}-rg",
  "resources": {
    "openai": {
      "endpoint": "https://rag-{project}-openai.openai.azure.com",
      "deployment": "gpt-4o",
      "embedding_deployment": "text-embedding-3-small"
    },
    "search": {
      "endpoint": "https://rag-{project}-search.search.windows.net",
      "sku": "standard",
      "replicas": 2
    },
    "appinsights": {
      "connection_string": "InstrumentationKey=...",
      "retention_days": 90
    }
  },
  "env_file": ".env",
  "duration_seconds": 420,
  "cost_estimate_monthly_usd": 174
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Recursos creados correctamente | 100% de recursos operativos | Health check post-despliegue |
| OpenAI responde | Respuesta en < 5s | Test query con prompt simple |
| Search accesible | Endpoint responde 200 | GET index status |
| App Insights recibe telemetría | Primer evento en < 60s | Flush de test event |
| .env generado con credenciales | Archivo existe y permisos 600 | Validación de formato |
| Tiempo total < 15 min | Despliegue completo | Timer end-to-end |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `QUOTA_EXCEEDED` | Sin cuota para OpenAI en la región | Sugerir región alternativa | Sí (otra región) |
| `REGION_UNAVAILABLE` | Modelo no disponible en región | Listar regiones con disponibilidad | Sí (otra región) |
| `RBAC_DENIED` | Sin permisos Contributor en subscription | Instrucciones para solicitar acceso | No |
| `NAME_CONFLICT` | Nombre de recurso ya existe | Añadir sufijo aleatorio | Sí (automático) |
| `DEPLOYMENT_TIMEOUT` | ARM template tarda > 15 min | Verificar estado parcial, reintentar | Sí (1 vez) |
| `NETWORK_ERROR` | Fallo de conexión a Azure | Verificar login az, retry | Sí (3 veces) |

---

## 6. Puntos de Integración

### Invocado Por
- `rag-onboarding` (Fase 7: despliegue automático tras aprobación)
- Usuario directo (despliegue standalone)

### Invoca A
- Azure CLI (`az group create`, `az deployment group create`)
- Plantillas Bicep en `rag-deployment-templates/`
- `rag-validator/` para health checks post-despliegue

### Salida Consumida Por
- `rag-indexer-specialist` (necesita endpoints y keys)
- `rag-chat` (necesita .env para conectar)
- `rag-cost-scaler` (necesita resource group para escalar)
- Todos los skills que interactúan con Azure

---

## 7. Restricciones

- Debe cumplir principios de constitución (consciencia de costes, observabilidad, sin leak de credenciales)
- No crear recursos fuera del resource group del proyecto
- Credenciales NUNCA en logs ni en output visible
- Usar Managed Identity donde sea posible
- Bicep templates versionados y reproducibles

---

## 8. Preguntas Abiertas

- [x] ¿Usar Bicep o Terraform? → Bicep (nativo Azure, sin state file)
- [x] ¿Managed Identity o API Keys? → API Keys para MVP, Managed Identity como upgrade
- [ ] ¿Soportar multi-subscription? → Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
