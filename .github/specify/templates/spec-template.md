# Plantilla de Spec — RAG Builder

> Usa esta plantilla al crear un nuevo spec para cualquier feature, skill o capacidad de agente.

---

# SPEC: {{FEATURE_NAME}}

**Estado:** Borrador | En Revisión | Aprobado | Implementado  
**Autor:** {{AUTHOR}}  
**Creado:** {{DATE}}  
**Versión:** 0.1.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | {{feature-name}} |
| **Propósito** | Descripción en una frase de lo que resuelve |
| **Tipo** | Agente / Skill / Script / Integración |
| **Prioridad** | P0 (Crítica) / P1 (Alta) / P2 (Media) / P3 (Baja) |
| **Entrada** | Qué lo dispara / qué datos recibe |
| **Salida** | Qué produce |

---

## 2. Motivación

**Problema:**  
Describe el punto de dolor o carencia que aborda esta feature.

**Valor:**  
Cuantifica el impacto (tiempo ahorrado, coste reducido, errores prevenidos).

**No-objetivos:**  
Qué NO cubre este spec explícitamente.

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "campo": "tipo — descripción"
}
```

**Campos obligatorios:** listarlos.  
**Campos opcionales:** listarlos con valores por defecto.

### 3.2 Esquema de Salida

```json
{
  "status": "success|warning|error",
  "result": {},
  "error": null,
  "metadata": {}
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| Requisito funcional 1 | Objetivo medible | Método de test |
| No-funcional (rendimiento) | < X ms / < Y tokens | Benchmark |
| Sin efectos secundarios | Cero cambios no intencionados | Log de auditoría |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `ERROR_CODE` | Cuándo ocurre | Qué hacer | Sí/No |

---

## 6. Puntos de Integración

### Invocado Por
- Qué agentes/skills lo invocan

### Invoca A
- APIs externas o skills internos de los que depende

### Salida Consumida Por
- Quién usa la salida

---

## 7. Restricciones

- Must comply with constitution principles (cost awareness, observability, no credential leaks)
- List any additional constraints specific to this feature

---

## 8. Open Questions

- [ ] Question that needs resolution before implementation

---

## 9. Changelog

| Version | Date | Changes |
|---|---|---|
| 0.1.0 | {{DATE}} | Initial draft |
