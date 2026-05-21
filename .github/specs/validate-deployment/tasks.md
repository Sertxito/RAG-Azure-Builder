# TAREAS: Validate Deployment

**Spec:** `specs/validate-deployment/spec.md`  
**Plan:** `specs/validate-deployment/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Azure CLI, azure-mgmt-*)
- [x] Branch creada: `feature/validate-deployment`

---

## Tareas

### Tarea 1: Validador de región y modelos

**Criterios de aceptación:**
- [x] `region_checker.py` verifica que la región soporta AI Search + OpenAI
- [x] Verifica disponibilidad de cada modelo solicitado en la región
- [x] Consulta cuota restante en subscription
- [x] Devuelve JSON estructurado con resultado por check

**Ficheros a crear/modificar:**
- `.github/skills/rag-validator/region_checker.py`

**Notas de implementación:**
Usar `az cognitiveservices model list` y `az search service list-skus` para verificar disponibilidad.

---

### Tarea 2: Calculadora de costes

**Criterios de aceptación:**
- [x] `cost_calculator.py` calcula desglose mensual por componente
- [x] Soporta los 3 tiers (minimal, standard, premium)
- [x] Incluye coste de inferencia estimado (basado en queries/mes)
- [x] Compara con budget y genera PROCEED/WARN/BLOCK

**Ficheros a crear/modificar:**
- `.github/skills/rag-validator/cost_calculator.py`

**Notas de implementación:**
Tablas de precios hardcodeadas (actualizables). Inference: gpt-4o $2.50/1M input + $10/1M output.

---

### Tarea 3: Validador de directrices RAG

**Criterios de aceptación:**
- [x] `guidelines_validator.py` verifica las 5 dimensiones de desafíos RAG
- [x] Verifica que agentes incluyen RAG Reference link
- [x] Valida architecture optimizer recommendations
- [x] Genera reporte de cumplimiento

**Ficheros a crear/modificar:**
- `.github/skills/rag-validator/guidelines_validator.py`
- `.github/agents/rag-validate-deployment.agent.md`
- `.github/instructions/agent-rag-validate-deployment.instructions.md`
- `.github/skills/rag-validator/SKILL.md`

---

### Tarea 4: Testing y documentación

**Criterios de aceptación:**
- [x] Validación correcta para regiones válidas e inválidas
- [x] Cálculo de costes matches tabla del README
- [x] BLOCK se dispara cuando budget < coste estimado
- [x] SKILL.md con ejemplos de uso

**Comandos de validación:**
```bash
# Test de validación
python .github/skills/rag-validator/guidelines_validator.py --action validate --region eastus

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/validate-deployment/spec.md"
```

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
