# TAREAS: Indexer Specialist

**Spec:** `specs/indexer/spec.md`  
**Plan:** `specs/indexer/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Azure Search + OpenAI desplegados)
- [x] Branch creada: `feature/indexer`

---

## Tareas

### Tarea 1: Parsers multi-formato

**Criterios de aceptación:**
- [x] Parser PDF: extrae texto + metadatos (páginas, título)
- [x] Parser Word: extrae texto + secciones + imágenes OCR
- [x] Parser PowerPoint: extrae texto de slides
- [x] Parser Excel: extrae datos tabulares como texto
- [x] Parser Markdown: preserva estructura de headings
- [x] Parser código: preserva estructura con metadata de lenguaje

**Ficheros a crear/modificar:**
- `.github/skills/rag-indexer/parsers/pdf_parser.py`
- `.github/skills/rag-indexer/parsers/docx_parser.py`
- `.github/skills/rag-indexer/parsers/pptx_parser.py`
- `.github/skills/rag-indexer/parsers/excel_parser.py`
- `.github/skills/rag-indexer/parsers/markdown_parser.py`
- `.github/skills/rag-indexer/parsers/code_parser.py`

**Notas de implementación:**
Cada parser devuelve lista de `TextBlock(text, metadata)`. Metadatos incluyen fuente, página/sección, formato.

---

### Tarea 2: Chunking y embeddings

**Criterios de aceptación:**
- [x] `chunker.py` divide texto en chunks de 400 tokens con 50 overlap
- [x] Respeta fronteras semánticas (no corta frases a mitad)
- [x] `embedder.py` genera embeddings en batches de 16
- [x] Backoff exponencial para rate limits de OpenAI

**Ficheros a crear/modificar:**
- `.github/skills/rag-indexer/chunker.py`
- `.github/skills/rag-indexer/embedder.py`

**Notas de implementación:**
Usar `tiktoken` para conteo exacto de tokens. Embedding model: `text-embedding-3-small` (1536 dims).

---

### Tarea 3: Orquestador de indexación

**Criterios de aceptación:**
- [x] `indexer.py` coordina: scan → parse → chunk → embed → upload
- [x] Acciones: index, reindex, status, delete
- [x] Progress reporting (X/Y documentos)
- [x] Estadísticas finales (docs, chunks, tokens, errores)

**Ficheros a crear/modificar:**
- `.github/skills/rag-indexer/indexer.py`
- `.github/agents/rag-indexer-specialist.agent.md`
- `.github/instructions/agent-rag-indexer.instructions.md`
- `.github/skills/rag-indexer/SKILL.md`

---

### Tarea 4: Testing y validación

**Criterios de aceptación:**
- [x] Indexar carpeta de test con 10 docs de formatos variados
- [x] Verificar que search retorna resultados relevantes
- [x] Tasa de error < 5% en docs válidos
- [x] Observabilidad: logs por fichero, métricas totales

**Comandos de validación:**
```bash
# Indexar carpeta de test
python .github/skills/rag-indexer/indexer.py --action index --path knowledge/

# Verificar índice
python .github/skills/rag-indexer/indexer.py --action status

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/indexer/spec.md"
```

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
