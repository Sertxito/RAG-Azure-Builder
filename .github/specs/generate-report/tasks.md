# TAREAS: Generate Report

**Spec:** `specs/generate-report/spec.md`  
**Plan:** `specs/generate-report/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Anthropic API, python-docx)
- [x] Branch creada: `feature/generate-report`

---

## Tareas

### Tarea 1: Generador de narrativa IA

**Criterios de aceptación:**
- [x] Llamada a Claude Opus 4.7 con prompt ejecutivo
- [x] Prompt incluye métricas como datos estructurados
- [x] Narrativa en tono ejecutivo (no técnico)
- [x] Secciones: resumen ejecutivo, hallazgos clave, métricas, recomendaciones

**Ficheros a crear/modificar:**
- `.github/skills/rag-report-generator/report_generator.py`
- `.github/skills/rag-report-generator/prompts/executive_prompt.md`

**Notas de implementación:**
El prompt instruye a Claude a escribir para un VP/C-level que tiene 5 minutos. Cifras concretas, no generalidades.

---

### Tarea 2: Renderizado DOCX profesional

**Criterios de aceptación:**
- [x] Portada con logo, título, cliente, fecha, autor
- [x] Tabla de contenidos automática
- [x] Secciones con formato consistente (headings, tablas, bullets)
- [x] Metadatos del documento (autor, título, subject)
- [x] Saltos de página entre secciones principales

**Ficheros a crear/modificar:**
- `.github/skills/rag-report-generator/templates/styles.py`
- `.github/skills/rag-report-generator/report_generator.py`

**Notas de implementación:**
Usar `python-docx` con estilos personalizados. Font: Calibri 11pt body, 14pt headings.

---

### Tarea 3: Validación de calidad

**Criterios de aceptación:**
- [x] 25 checks automáticos de calidad (portada, métricas, formato)
- [x] Genera score de calidad del informe
- [x] Falla si checks críticos no pasan

**Ficheros a crear/modificar:**
- `.github/skills/rag-report-generator/report_generator.py` (sección de validación)

---

### Tarea 4: Testing y documentación

**Criterios de aceptación:**
- [x] Generación end-to-end produce DOCX válido
- [x] DOCX abre correctamente en Word
- [x] SKILL.md documenta tipos de informe y parámetros
- [x] README con ejemplo de uso

**Comandos de validación:**
```bash
# Generar informe de test
python .github/skills/rag-report-generator/report_generator.py --type rag_implementation --client "Test Corp"

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/generate-report/spec.md"
```

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
