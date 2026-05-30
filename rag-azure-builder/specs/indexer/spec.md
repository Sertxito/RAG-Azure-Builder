# SPEC: Indexer Specialist

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | indexer |
| **Propósito** | Indexar documentos en Azure AI Search: fragmentar, generar embeddings, subir chunks con metadatos |
| **Tipo** | Agente (Procesamiento de documentos) |
| **Prioridad** | P0 (Crítica — sin índice no hay búsqueda) |
| **Entrada** | Carpeta knowledge/ con documentos + credenciales Azure |
| **Salida** | Índice en Azure Search con chunks, embeddings y metadatos |

---

## 2. Motivación

**Problema:**  
Indexar documentos manualmente en Azure Search requiere:
- Parsear cada formato (PDF, Word, PPT, código...)
- Decidir estrategia de chunking
- Generar embeddings vía API
- Subir con schema correcto
- Validar calidad de búsqueda

**Valor:**  
- Soporta 8+ formatos automáticamente
- Chunking inteligente (respeta fronteras semánticas)
- Embeddings generados en batch (eficiente en tokens)
- Metadatos extraídos automáticamente (fuente, sección, página)
- Métricas de calidad post-indexación

**No-objetivos:**  
- NO despliega infraestructura (eso es azure-setup)
- NO gestiona SharePoint (eso es sharepoint-setup)
- NO responde consultas (eso es chat/qa-engine)

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "action": "index|reindex|status|delete",
  "knowledge_path": "knowledge/",
  "index_name": "rag-documents",
  "chunk_size_tokens": 400,
  "chunk_overlap_tokens": 50,
  "embedding_model": "text-embedding-3-small",
  "formats": ["pdf", "docx", "pptx", "xlsx", "md", "py", "sql", "txt"],
  "ocr_enabled": true,
  "language_analyzer": "es.microsoft"
}
```

**Campos obligatorios:** `action`, `knowledge_path`  
**Campos opcionales:** todos los demás con defaults razonables

### 3.2 Esquema de Salida

```json
{
  "status": "success|partial|error",
  "index_name": "rag-documents",
  "statistics": {
    "files_processed": 18,
    "files_failed": 2,
    "chunks_total": 1950,
    "chunks_average_tokens": 380,
    "embeddings_generated": 1950,
    "index_size_mb": 450,
    "processing_time_seconds": 240
  },
  "failed_files": [
    {"file": "corrupted.pdf", "reason": "OCR failed — file corrupted"}
  ],
  "quality_metrics": {
    "coverage": 0.98,
    "avg_chunk_relevance": 0.87,
    "duplicate_chunks": 0
  }
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Todos los formatos soportados | 8 formatos parseables | Test con archivo de cada tipo |
| Chunking preserva semántica | 0 chunks cortados a mitad de frase | Inspección manual sample |
| Embeddings consistentes | Mismo modelo para todos | Verificar metadata del índice |
| Metadatos completos | source, section, page en cada chunk | Query de validación |
| Rendimiento aceptable | < 5 min para 100 docs medianos | Benchmark |
| Indexación incremental | Solo procesa docs nuevos/modificados | Comparar timestamps |
| Calidad de búsqueda | Top-5 contiene respuesta correcta >80% | Test queries predefinidas |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `OCR_FAILED` | PDF/imagen ilegible | Saltar archivo, reportar en failed_files | No |
| `EMBEDDING_QUOTA` | Rate limit de OpenAI | Backoff exponencial, retry | Sí (con delay) |
| `INDEX_FULL` | Tier de Search sin capacidad | Avisar usuario, sugerir upgrade | No |
| `FORMAT_UNSUPPORTED` | Archivo binario/ejecutable | Saltar, reportar | No |
| `ENCODING_ERROR` | Archivo con encoding roto | Intentar UTF-8 fallback | Sí (1 vez) |
| `SEARCH_UNAVAILABLE` | Azure Search no responde | Retry con backoff | Sí (3 veces) |

---

## 6. Puntos de Integración

### Invocado Por
- `rag-onboarding` (Fase 8: indexación post-despliegue)
- Usuario directo (re-indexación manual)
- `rag-sharepoint-setup` (modo local: indexar docs descargados)

### Invoca A
- Azure OpenAI API (generación de embeddings)
- Azure AI Search API (upload de chunks)
- `rag-storage-connector` (lectura de documentos)
- `rag-agent-instrumentation` (telemetría)

### Salida Consumida Por
- `rag-chat` / `rag-qa-engine` (consultan el índice)
- `rag-diagnostics` (monitoriza estado del índice)
- `rag-onboarding` (muestra estadísticas al usuario)

---

## 7. Restricciones

- Chunking debe respetar fronteras de sección/párrafo
- NUNCA enviar contenido sensible a logs
- Embeddings batch size ≤ 16 (rate limit friendly)
- Mantener manifest de archivos procesados (evitar re-procesamiento)
- El índice debe ser queryable durante re-indexación (zero downtime)

---

## 8. Preguntas Abiertas

- [x] ¿Chunking fijo o semántico? → Semántico (por secciones) con fallback a fijo
- [x] ¿Overlap entre chunks? → Sí, 50 tokens por defecto
- [ ] ¿Soportar indexación streaming? (docs que llegan continuamente) → Fase 2
- [ ] ¿Deduplicación cross-document? → Evaluar en Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
