# TAREAS: Onboarding Wizard

**Spec:** `specs/onboarding/spec.md`  
**Plan:** `specs/onboarding/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (azure-setup, indexer, validate-deployment, cost-analyst)
- [x] Branch creada: `feature/onboarding`

---

## Tareas

### Tarea 1: Definición del agente orquestador

**Criterios de aceptación:**
- [x] `.github/agents/rag-onboarding.agent.md` creado con 9 fases documentadas
- [x] Incluye RAG Reference link
- [x] Describe delegación a sub-agentes (azure-setup, indexer, validate-deployment)
- [x] Instrucciones en español

**Ficheros a crear/modificar:**
- `.github/agents/rag-onboarding.agent.md`
- `.github/instructions/agent-rag-onboarding.instructions.md`

**Notas de implementación:**
El agente es un orquestador que delega trabajo a otros agentes/skills. Cada fase tiene criterios de salida claros.

---

### Tarea 2: Skill de orquestación

**Criterios de aceptación:**
- [x] `.github/skills/rag-orchestration/SKILL.md` define las 9 fases
- [x] `orchestrator.py` implementa lógica de fases con estado persistente
- [x] Cada fase tiene input/output definido
- [x] Gate de aprobación humana en Fase 6

**Ficheros a crear/modificar:**
- `.github/skills/rag-orchestration/SKILL.md`
- `.github/skills/rag-orchestration/orchestrator.py`

**Notas de implementación:**
Estado guardado en JSON para permitir resume si se interrumpe.

---

### Tarea 3: Testing y validación

**Criterios de aceptación:**
- [x] Flujo end-to-end funciona (Fase 1 a 9)
- [x] Gate de aprobación bloquea sin confirmación
- [x] Manejo de errores: user_cancelled, quota_exceeded, no_documents
- [x] Observabilidad: logs por cada fase

**Comandos de validación:**
```bash
# Test de flujo completo
python .github/skills/rag-orchestration/orchestrator.py --test

# Validar spec compliance
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/onboarding/spec.md"
```

---

### Tarea 4: Documentación e integración

**Criterios de aceptación:**
- [x] SKILL.md documentado con ejemplos de uso
- [x] README.md del skill actualizado
- [x] Agent referencia correctamente los sub-agentes
- [x] Mencionado en `.github/README.md` principal

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
