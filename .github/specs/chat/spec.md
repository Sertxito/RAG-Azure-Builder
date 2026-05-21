# SPEC: Chat (RAG Q&A)

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | chat |
| **Propósito** | Chat conversacional sobre documentos indexados: búsqueda semántica + generación con citas |
| **Tipo** | Agente (Interfaz de usuario final) |
| **Prioridad** | P0 (Crítica — es la experiencia principal del usuario) |
| **Entrada** | Pregunta en lenguaje natural + historial de conversación |
| **Salida** | Respuesta con citas a documentos fuente |

---

## 2. Motivación

**Problema:**  
Los usuarios tienen miles de documentos pero no pueden encontrar la información relevante:
- Búsqueda manual: 5-10 min por pregunta
- Resultados inconsistentes (depende de quién busca)
- Sin síntesis (el usuario debe leer y conectar información)

**Valor:**  
- Respuesta en 2-3 segundos (vs 5-10 min manual)
- Citas a fuentes (verificable, no alucinaciones)
- Contexto conversacional (follow-ups sin repetir contexto)
- Consistencia (misma calidad siempre)

**No-objetivos:**  
- NO modifica documentos (solo lectura)
- NO genera informes largos (eso es generate-report)
- NO gestiona infraestructura

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "query": "string — pregunta del usuario",
  "conversation_history": [
    {"role": "user", "content": "..."},
    {"role": "assistant", "content": "..."}
  ],
  "search_mode": "hybrid|semantic|keyword",
  "top_k": 5,
  "temperature": 0.3,
  "language": "es",
  "filters": {
    "source_type": "pdf|docx|all",
    "date_range": {"from": "2024-01-01", "to": null}
  }
}
```

**Campos obligatorios:** `query`  
**Campos opcionales:** `conversation_history` (default: []), `search_mode` (default: hybrid), `top_k` (default: 5), `temperature` (default: 0.3), `language` (default: es), `filters` (default: ninguno)

### 3.2 Esquema de Salida

```json
{
  "answer": "string — respuesta generada",
  "citations": [
    {
      "text": "fragmento citado",
      "source": "HR_Handbook_2024.pdf",
      "section": "2.1: Política PTO",
      "page": 12,
      "relevance_score": 0.94
    }
  ],
  "follow_ups": [
    "¿Cuántos días corresponden a empleados remotos?",
    "¿Hay excepciones para contratos temporales?"
  ],
  "metadata": {
    "search_latency_ms": 230,
    "generation_latency_ms": 1800,
    "total_latency_ms": 2030,
    "tokens_used": 450,
    "cost_usd": 0.03,
    "chunks_retrieved": 5,
    "model": "gpt-4o"
  }
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Latencia end-to-end | < 5 segundos P95 | Telemetría App Insights |
| Respuestas con citas | ≥ 1 cita por respuesta | Validación automática |
| Precisión (relevancia) | Top-5 contiene respuesta >85% | Evaluación con test set |
| No alucinaciones | 0% respuestas sin fundamento | Review manual periódico |
| Contexto conversacional | Mantiene coherencia 5+ turnos | Test multi-turn |
| Coste por consulta | < $0.05 | Tracking de tokens |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `NO_RESULTS` | Búsqueda no encuentra chunks relevantes | Responder "No encontré información..." con sugerencias | No |
| `OPENAI_TIMEOUT` | gpt-4o no responde en 30s | Retry 1 vez, después error amigable | Sí (1 vez) |
| `SEARCH_ERROR` | Azure Search no disponible | Mensaje de error + log | Sí (3 veces) |
| `TOKEN_LIMIT` | Contexto excede ventana del modelo | Truncar chunks menos relevantes | Sí (automático) |
| `RATE_LIMIT` | Demasiadas consultas simultáneas | Backoff + mensaje "intenta en X segundos" | Sí (con delay) |
| `FILTER_EMPTY` | Filtros demasiado restrictivos | Sugerir ampliar filtros | No |

---

## 6. Puntos de Integración

### Invocado Por
- Usuario directo (conversación interactiva)
- `rag-api-server` (endpoint REST)
- `rag-query-cli` (consultas por terminal)

### Invoca A
- Azure AI Search (retrieval de chunks)
- Azure OpenAI gpt-4o (generación de respuesta)
- `rag-agent-instrumentation` (telemetría de cada consulta)

### Salida Consumida Por
- Usuario final (la respuesta)
- `rag-diagnostics` (métricas de uso)
- `rag-generate-report` (puede citar historial de consultas)

---

## 7. Restricciones

- NUNCA inventar información no presente en los chunks recuperados
- Si no hay información suficiente, decirlo explícitamente
- Siempre incluir al menos 1 cita verificable
- Respetar filtros de seguridad a nivel documento (DLS)
- Temperatura baja (0.3) para minimizar creatividad no deseada
- Idioma de respuesta = idioma de la pregunta (auto-detectar)

---

## 8. Preguntas Abiertas

- [x] ¿Modelo para generación? → gpt-4o (balance calidad/coste)
- [x] ¿Cuántos chunks enviar al LLM? → Top 5 por defecto
- [x] ¿Streaming de respuesta? → Sí, token por token
- [ ] ¿Memoria persistente entre sesiones? → Fase 2
- [ ] ¿Feedback del usuario (thumbs up/down)? → Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
