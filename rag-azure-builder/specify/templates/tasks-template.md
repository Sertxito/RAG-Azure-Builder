# Plantilla de Tareas — RAG Builder

> Usa esta plantilla después de que un plan sea aprobado para dividir el trabajo en trozos implementables.

---

# TAREAS: {{FEATURE_NAME}}

**Spec:** `specs/{{feature-name}}/spec.md`  
**Plan:** `specs/{{feature-name}}/plan.md`  
**Estado:** No Iniciado | En Progreso | Completado  
**Autor:** {{AUTHOR}}  
**Creado:** {{DATE}}

---

## Prerequisitos

- [ ] Spec aprobado
- [ ] Plan aprobado
- [ ] Dependencias disponibles (listarlas)
- [ ] Branch creada: `feature/{{feature-name}}`

---

## Tareas

### Tarea 1: {{Título}}

**Criterios de aceptación:**
- [ ] Criterio 1
- [ ] Criterio 2

**Ficheros a crear/modificar:**
- `path/to/file.py`

**Notas de implementación:**
Guía breve para el agente implementador.

---

### Tarea 2: {{Título}}

**Criterios de aceptación:**
- [ ] Criterio 1
- [ ] Criterio 2

**Ficheros a crear/modificar:**
- `path/to/file.py`

**Notas de implementación:**
Guía breve.

---

### Tarea 3: Testing y Validación

**Criterios de aceptación:**
- [ ] Todos los criterios de éxito del spec pasan
- [ ] Manejo de errores testeado según tabla de errores
- [ ] Observabilidad verificada (logs, métricas)
- [ ] Cumplimiento de constitución comprobado

**Comandos de validación:**
```bash
# Ejecutar tests
python -m pytest specs/{{feature-name}}/tests/ -v

# Validar esquema de salida
python -c "import json; json.loads(open('outputs/result.json').read())"

# Comprobar observabilidad
grep "{{feature-name}}" outputs/rag.log
```

---

### Tarea 4: Documentación e Integración

**Criterios de aceptación:**
- [ ] SKILL.md actualizado (si aplica)
- [ ] Agent .agent.md referencia la nueva capacidad
- [ ] README actualizado si es cambio visible al usuario

---

## Checklist de Completitud

- [ ] Todas las tareas completadas
- [ ] Criterios de éxito del spec validados
- [ ] Cumplimiento de constitución verificado
- [ ] PR listo para revisión
