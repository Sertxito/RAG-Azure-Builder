# TAREAS: SharePoint Setup

**Spec:** `specs/sharepoint-setup/spec.md`  
**Plan:** `specs/sharepoint-setup/plan.md`  
**Estado:** Completado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15

---

## Prerequisitos

- [x] Spec aprobado
- [x] Plan aprobado
- [x] Dependencias disponibles (Graph API, MSAL, Azure Search)
- [x] Branch creada: `feature/sharepoint-setup`

---

## Tareas

### Tarea 1: Autenticación OAuth/MSAL

**Criterios de aceptación:**
- [x] `oauth_helper.py` implementa flujo interactivo (device code) y service principal
- [x] Token refresh automático
- [x] Almacena tokens de forma segura (no en plaintext)
- [x] Soporta multi-tenant

**Ficheros a crear/modificar:**
- `.github/skills/rag-sharepoint-connector/oauth_helper.py`

**Notas de implementación:**
Usar `msal` con `PublicClientApplication` para interactivo y `ConfidentialClientApplication` para service principal.

---

### Tarea 2: Cliente Microsoft Graph

**Criterios de aceptación:**
- [x] `graph_client.py` resuelve site URL → site ID → drive ID
- [x] Lista archivos recursivamente con paginación
- [x] Descarga archivos individuales
- [x] Filtra por extensiones soportadas

**Ficheros a crear/modificar:**
- `.github/skills/rag-sharepoint-connector/graph_client.py`

**Notas de implementación:**
Endpoint: `GET /sites/{site-id}/drives/{drive-id}/root/children`. Paginación con `@odata.nextLink`.

---

### Tarea 3: Conector dual mode

**Criterios de aceptación:**
- [x] `sharepoint_connector.py` implementa setup, sync, status, disconnect
- [x] Modo profesional: crea data source + indexer en Azure Search
- [x] Modo local: descarga a `knowledge/sharepoint/`, preserva estructura
- [x] Status muestra última sincronización y conteo de docs

**Ficheros a crear/modificar:**
- `.github/skills/rag-sharepoint-connector/sharepoint_connector.py`
- `.github/agents/rag-sharepoint-setup.agent.md` (si no existe se usa el genérico)
- `.github/instructions/agent-rag-sharepoint-setup.instructions.md`
- `.github/skills/rag-sharepoint-connector/SKILL.md`

---

### Tarea 4: Testing y documentación

**Criterios de aceptación:**
- [x] Conexión exitosa a site de pruebas
- [x] Modo local descarga correctamente
- [x] Modo profesional crea indexer funcional
- [x] README con guía paso a paso de permisos Entra ID

**Comandos de validación:**
```bash
# Test de conexión
python .github/skills/rag-sharepoint-connector/sharepoint_connector.py --action status

# Validar spec
.\.specify\scripts\Validate-Spec.ps1 -SpecPath "specs/sharepoint-setup/spec.md"
```

---

## Checklist de Completitud

- [x] Todas las tareas completadas
- [x] Criterios de éxito del spec validados
- [x] Cumplimiento de constitución verificado
- [x] Implementación funcional
