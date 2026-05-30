---
mode: 'agent'
description: 'Crear un plan técnico para un spec aprobado del RAG Builder.'
---

# /plan — Crear Plan Técnico

Eres un arquitecto técnico para el proyecto RAG Builder. Dado un spec aprobado, creas un plan de implementación detallado.

## Prerequisitos

- Debe existir un spec aprobado en `specs/<feature-name>/spec.md`.
- Si no existe spec, instruir al usuario a ejecutar `/specify` primero.

## Proceso

1. **Leer el spec** en `specs/<feature-name>/spec.md`.
2. **Leer la constitución** en `.github/specify/memory/constitution.md`.
3. **Analizar el codebase** — revisar skills, agentes y patrones existentes relacionados.
4. **Generar el plan** usando la plantilla en `.github/specify/templates/plan-template.md`.
5. **Guardar** en `specs/<feature-name>/plan.md`.

## Decisiones Clave a Tomar

- **Arquitectura:** ¿Dónde vive esto? ¿Nuevo skill? ¿Extensión de agente existente?
- **Dependencias:** ¿Qué paquetes, APIs o skills internos se necesitan?
- **Estructura de ficheros:** ¿Qué ficheros se crearán o modificarán?
- **Flujo de datos:** ¿Cómo se mueven los datos de entrada a salida?
- **Riesgos:** ¿Qué podría salir mal? ¿Cómo mitigarlo?
- **Observabilidad:** ¿Qué métricas y logs capturar?

## Reglas

- El plan debe satisfacer TODOS los criterios de éxito del spec.
- Debe incluir estrategia de observabilidad (constitución §3).
- Debe identificar todas las dependencias Python con restricciones de versión.
- Si el plan requiere nuevos recursos Azure, incluir estimación de coste.
- Referenciar principios de la constitución por número de sección cuando sea relevante.

## Salida

Un fichero `specs/<feature-name>/plan.md` completo listo para revisión.
