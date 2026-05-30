# TAREAS: Cost Scaler

**Spec:** `specs/cost-scaler/spec.md`  
**Plan:** `specs/cost-scaler/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Azure CLI, infra RAG desplegada)
- [x] Branch creada: `feature/cost-scaler`

---

## Tareas

### Tarea 1: Script PowerShell principal

**Criterios de aceptación:**
- [x] `cost-scaler.ps1` implementa 4 acciones: show_current, list_tiers, change_to, create_alerts
- [x] `show_current`: consulta SKUs y calcula coste mensual actual
- [x] `list_tiers`: muestra tabla de 3 tiers con desglose
- [x] `change_to`: dry-run con diff de coste, requiere confirmación
- [x] `create_alerts`: crea budget + action group + alerta email

**Ficheros a crear/modificar:**
- `.github/skills/rag-cost-scaler/cost-scaler.ps1`

**Notas de implementación:**
Usar `az search service update --sku` para cambiar tier. Verificar que nuevo tier soporta tamaño actual antes de downscale.

---

### Tarea 2: Definición del agente

**Criterios de aceptación:**
- [x] `.github/agents/rag-cost-scaler.agent.md` con RAG Reference
- [x] Instructions detallan comportamiento y safety checks
- [x] SKILL.md documenta uso y ejemplos

**Ficheros a crear/modificar:**
- `.github/agents/rag-cost-scaler.agent.md`
- `.github/skills/rag-cost-scaler/SKILL.md`

---

### Tarea 3: Testing y validación

**Criterios de aceptación:**
- [x] Dry-run muestra cambios sin aplicar
- [x] Confirmación requerida antes de ejecutar
- [x] Rollback documentado si el cambio falla
- [x] Alertas se crean correctamente

**Comandos de validación:**
```powershell
# Ver estado actual
.\.github\skills\rag-cost-scaler\cost-scaler.ps1 -Action show_current -ResourceGroup "rag-test-rg"

# Dry-run de cambio
.\.github\skills\rag-cost-scaler\cost-scaler.ps1 -Action change_to -Tier minimal -DryRun

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/cost-scaler/spec.md"
```

---

### Tarea 4: Documentación e integración

**Criterios de aceptación:**
- [x] README con ejemplos de uso
- [x] Tabla de precios actualizada en README principal
- [x] Mencionado en sección "Costes estimados" del README

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
