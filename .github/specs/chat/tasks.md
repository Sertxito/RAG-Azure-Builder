# TAREAS: Chat (RAG Q&A)

**Spec:** `specs/chat/spec.md`  
**Plan:** `specs/chat/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Azure Search poblado, OpenAI desplegado)
- [x] Branch creada: `feature/chat`

---

## Tareas

### Tarea 1: Motor de búsqueda híbrida

**Criterios de aceptación:**
- [x] `search_client.py` implementa búsqueda hybrid (keyword + vector)
- [x] Semantic ranking habilitado
- [x] Configurable: top_k, filtros, modo de búsqueda
- [x] Devuelve chunks con score y metadatos

**Ficheros a crear/modificar:**
- `.github/skills/rag-qa-engine/search_client.py`

**Notas de implementación:**
Usar `azure-search-documents` con `SearchClient` y `VectorizableTextQuery`.

---

### Tarea 2: Motor de generación con citas

**Criterios de aceptación:**
- [x] `qa_engine.py` genera respuestas citando fuentes
- [x] Reformulación contextual de queries con historial
- [x] Follow-ups sugeridos automáticamente
- [x] Respeta token budget (no inyectar documentos completos)

**Ficheros a crear/modificar:**
- `.github/skills/rag-qa-engine/qa_engine.py`
- `.github/skills/rag-qa-engine/prompt_templates.py`

**Notas de implementación:**
System prompt instruye a gpt-4o a citar con formato `[fuente: nombre, pág X]`.

---

### Tarea 3: Agente conversacional

**Criterios de aceptación:**
- [x] `.github/agents/rag-chat.agent.md` con RAG Reference
- [x] Mantiene historial conversacional (ventana de 5 turnos)
- [x] Instrucciones detallan reformulación y citas

**Ficheros a crear/modificar:**
- `.github/agents/rag-chat.agent.md`
- `.github/instructions/agent-rag-chat.instructions.md`
- `.github/skills/rag-qa-engine/SKILL.md`

---

### Tarea 4: Testing y validación

**Criterios de aceptación:**
- [x] Latencia end-to-end < 5s (P95)
- [x] Respuestas incluyen ≥ 1 cita verificable
- [x] Multi-turn mantiene coherencia 5+ turnos
- [x] No alucinaciones en test set de 20 preguntas

**Comandos de validación:**
```bash
# Test de query individual
python .github/skills/rag-qa-engine/qa_engine.py --query "¿Qué dice la política PTO?"

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/chat/spec.md"
```

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
