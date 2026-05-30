# SPEC: Generate Report

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | generate-report |
| **Propósito** | Generar informes ejecutivos profesionales en DOCX con narrativa IA, métricas cuantificadas y recomendaciones estratégicas |
| **Tipo** | Agente (Generación de documentos) |
| **Prioridad** | P1 (Alta — deliverable final para clientes) |
| **Entrada** | Tipo de informe, métricas del proyecto, nombre de cliente |
| **Salida** | Archivo DOCX profesional listo para presentar |

---

## 2. Motivación

**Problema:**  
Generar un informe ejecutivo de calidad profesional requiere:
- 2-4 horas de redacción manual
- Conocimiento de diseño documental (portadas, tipografía)
- Capacidad de síntesis (convertir datos técnicos en narrativa ejecutiva)
- Consistencia de tono y formato entre informes

**Valor:**  
- Reduce de 2-4 horas a 15 minutos
- Calidad consistente (25 checks de validación automáticos)
- Tono ejecutivo (generado por Claude Opus 4.7, no plantilla)
- Métricas cuantificadas (ROI, ahorro, precision del sistema)
- Formato profesional (portada, metadatos, tablas, saltos de página)

**No-objetivos:**  
- NO es un log técnico (es para stakeholders no técnicos)
- NO reemplaza presentaciones PPT (es documento para lectura)
- NO genera informes recurrentes automáticos (es bajo demanda)

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "report_type": "rag_implementation|document_analysis|cost_assessment",
  "client_name": "MENSADEF",
  "project_name": "Búsqueda Inteligente",
  "author": "Sergio Hierro",
  "metrics": {
    "documents_indexed": 2345,
    "total_size_gb": 15.3,
    "system_accuracy_pct": 97,
    "key_benefit": "búsqueda mejoró de 15min a 30seg",
    "search_latency_ms": 2300,
    "queries_monthly": 1500,
    "cost_monthly_usd": 209
  },
  "challenge_before": "Búsqueda manual en 1,000+ documentos dispersos",
  "next_step": "Integrar con SharePoint para sincronización automática",
  "auto_collect_metrics": true
}
```

**Campos obligatorios:** `report_type`, `client_name`, `project_name`, `author`  
**Campos opcionales:** `metrics` (auto-recopilados si `auto_collect_metrics=true`), `challenge_before`, `next_step`

### 3.2 Esquema de Salida

```json
{
  "status": "success|error",
  "output_file": "outputs/informe-ejecutivo-20260514.docx",
  "pages": 8,
  "sections": {
    "executive_summary": {"words": 287, "paragraphs": 3},
    "findings": {"key_achievements": 5},
    "recommendations": {"count": 4, "priorities": {"high": 1, "medium": 2, "low": 1}},
    "timeline": {"phases": 4, "weeks_total": 8},
    "risks": {"identified": 3, "mitigations": 3}
  },
  "quality_score": {
    "checks_passed": 25,
    "checks_total": 25,
    "issues": []
  },
  "generation_model": "claude-opus-4.7",
  "generation_time_seconds": 45
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Formato profesional | Portada + metadatos + tablas + saltos | Abrir en Word y verificar |
| Narrativa no-template | Sin frases genéricas detectadas | Checklist de 25 puntos |
| Métricas cuantificadas | ≥ 3 cifras concretas en resumen | Validación automática |
| Recomendaciones accionables | Cada una con: acción + beneficio + plazo | Inspección de estructura |
| Tono profesional | Sin jerga técnica excesiva | Review de legibilidad |
| Generación < 2 min | Timer de producción | Cronómetro |
| DOCX abre sin errores | Compatible Word 2016+ | Test apertura |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `MODEL_UNAVAILABLE` | Claude Opus no responde | Fallback a gpt-4o (calidad menor) | Sí (otro modelo) |
| `METRICS_MISSING` | Auto-recopilación falla | Pedir métricas manuales al usuario | No |
| `DOCX_GENERATION` | Error en librería python-docx | Log + sugerir regenerar | Sí (1 vez) |
| `QUALITY_FAILED` | < 20/25 checks pasan | Regenerar sección problemática | Sí (1 vez) |
| `OUTPUT_DIR_MISSING` | Carpeta outputs/ no existe | Crearla automáticamente | Sí (auto) |

---

## 6. Puntos de Integración

### Invocado Por
- Usuario directo (generar informe bajo demanda)
- Workflow de cierre de proyecto

### Invoca A
- Claude Opus 4.7 / Azure OpenAI (generación de narrativa)
- `rag-diagnostics` (recopilación automática de métricas)
- `rag-cost-analyst` (cálculo de ROI)
- python-docx (generación del archivo)
- `rag-agent-instrumentation` (telemetría)

### Salida Consumida Por
- Cliente final (presentación a stakeholders)
- Equipo de proyecto (documentación de cierre)
- Archivo del proyecto (registro de resultados)

---

## 7. Restricciones

- Generar con Claude Opus 4.7 (probado en producción para calidad narrativa)
- NO incluir datos confidenciales sin autorización explícita
- Formato DOCX estándar (compatible Office 2016+)
- Idioma del informe = español (salvo override)
- Resumen ejecutivo ≤ 300 palabras (brevedad ejecutiva)
- Todas las afirmaciones deben estar respaldadas por métricas

---

## 8. Preguntas Abiertas

- [x] ¿Modelo para generación? → Claude Opus 4.7 (mejor narrativa)
- [x] ¿Formato de salida? → DOCX (universal, editable)
- [ ] ¿Soportar PDF como salida alternativa? → Fase 2
- [ ] ¿Plantillas personalizables por cliente? (logos, colores) → Fase 2
- [ ] ¿Versión inglés del informe? → Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
