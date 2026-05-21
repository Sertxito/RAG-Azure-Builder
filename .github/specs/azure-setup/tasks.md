# TAREAS: Azure Setup

**Spec:** `specs/azure-setup/spec.md`  
**Plan:** `specs/azure-setup/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Azure CLI, Bicep)
- [x] Branch creada: `feature/azure-setup`

---

## Tareas

### Tarea 1: Plantillas Bicep

**Criterios de aceptación:**
- [x] `main.bicep` orquesta los 3 módulos
- [x] `modules/openai.bicep` despliega Azure OpenAI con modelos configurables
- [x] `modules/search.bicep` despliega AI Search con semantic config
- [x] `modules/insights.bicep` despliega App Insights + Log Analytics
- [x] Parámetros derivados del tier (SKU, réplicas, retención)

**Ficheros a crear/modificar:**
- `.github/skills/rag-deployment-templates/bicep/main.bicep`
- `.github/skills/rag-deployment-templates/bicep/modules/openai.bicep`
- `.github/skills/rag-deployment-templates/bicep/modules/search.bicep`
- `.github/skills/rag-deployment-templates/bicep/modules/insights.bicep`

**Notas de implementación:**
Tier mínimo → Basic Search, Standard → Standard 1 SU, Premium → Standard 3 SUs.

---

### Tarea 2: Script orquestador de despliegue

**Criterios de aceptación:**
- [x] `deploy.sh` ejecuta todo el flujo (validate → create RG → deploy → verify → .env)
- [x] Verifica Azure CLI autenticado antes de empezar
- [x] Genera `.env` con endpoints y keys
- [x] Nunca expone credenciales en stdout

**Ficheros a crear/modificar:**
- `.github/skills/rag-deployment-templates/deploy.sh`

**Notas de implementación:**
Usar `az deployment group create` con output en JSON para capturar keys.

---

### Tarea 3: Definición del agente

**Criterios de aceptación:**
- [x] `.github/agents/rag-azure-setup.agent.md` con RAG Reference
- [x] Instructions define comportamiento detallado
- [x] SKILL.md documenta capacidades

**Ficheros a crear/modificar:**
- `.github/agents/rag-azure-setup.agent.md`
- `.github/instructions/agent-rag-azure-setup.instructions.md`
- `.github/skills/rag-deployment-templates/SKILL.md`

---

### Tarea 4: Testing y validación

**Criterios de aceptación:**
- [x] Despliegue exitoso en eastus (tier minimal)
- [x] Verificación de conectividad a los 3 recursos
- [x] `.env` generado correctamente
- [x] Manejo de errores: cuota, permisos, región

**Comandos de validación:**
```bash
# Dry-run Bicep
az deployment group what-if --resource-group test-rg --template-file main.bicep

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/azure-setup/spec.md"
```

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
