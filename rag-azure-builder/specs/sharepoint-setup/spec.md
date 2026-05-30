# SPEC: SharePoint Setup

**Estado:** Aprobado  
**Autor:** RAG Builder Team  
**Creado:** 2026-05-15  
**Versión:** 1.0.0

---

## 1. Resumen

| Atributo | Valor |
|----------|-------|
| **Nombre** | sharepoint-setup |
| **Propósito** | Integrar SharePoint como fuente de documentos para RAG: modo profesional (indexador Azure Search) o local (descarga) |
| **Tipo** | Agente (Integración de fuentes de datos) |
| **Prioridad** | P1 (Alta — muchas organizaciones tienen docs en SharePoint) |
| **Entrada** | URL del sitio SharePoint, credenciales OAuth, modo elegido |
| **Salida** | Documentos disponibles para RAG (indexados directamente o descargados) |

---

## 2. Motivación

**Problema:**  
El conocimiento corporativo a menudo reside en SharePoint:
- Políticas RRHH, procedimientos, normativas
- Documentos de proyecto, actas, presentaciones
- Manuales técnicos, guías operativas

Sin integración, estos documentos no se incluyen en el RAG y las respuestas están incompletas.

**Valor:**  
- Acceso unificado a documentos SharePoint + locales
- Modo profesional: sincronización automática (sin intervención)
- Modo local: descarga puntual (sin dependencia continua)
- OAuth seguro (tokens, no contraseñas)
- Coexiste con documentos locales en knowledge/

**No-objetivos:**  
- NO escribe/modifica documentos en SharePoint (solo lectura)
- NO reemplaza SharePoint como sistema de gestión documental
- NO soporta OneDrive personal (solo sitios SharePoint corporativos)

---

## 3. Contrato de Entrada/Salida

### 3.1 Esquema de Entrada

```json
{
  "action": "setup|sync|status|disconnect",
  "mode": "professional|local",
  "sharepoint_url": "https://contoso.sharepoint.com/sites/Docs",
  "tenant_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "client_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "client_secret": "optional — para service principal",
  "auth_method": "interactive|service_principal",
  "target_library": "Documents",
  "folder_filter": "/Policies/*",
  "file_types": ["pdf", "docx", "pptx", "xlsx"]
}
```

**Campos obligatorios:** `action`, `mode`, `sharepoint_url`, `tenant_id`, `client_id`  
**Campos opcionales:** `client_secret` (solo service_principal), `auth_method` (default: interactive), `target_library` (default: Documents), `folder_filter` (default: todo), `file_types` (default: todos los soportados)

### 3.2 Esquema de Salida

```json
{
  "status": "success|error",
  "mode": "professional",
  "site_info": {
    "name": "Documentos Finanzas",
    "site_id": "xxxxx",
    "drive_id": "xxxxx",
    "documents_found": 2345,
    "total_size_gb": 15.3
  },
  "configuration": {
    "indexer_config_file": "scripts/sharepoint-config.json",
    "sync_schedule": "hourly",
    "last_sync": null
  },
  "mode_local_result": {
    "downloaded_files": 2345,
    "destination": "knowledge/sharepoint-2026-05-14_14-30-45/",
    "manifest_file": "knowledge/sharepoint-2026-05-14_14-30-45/manifest.json"
  }
}
```

---

## 4. Criterios de Éxito

| Requisito | Métrica | Cómo Validar |
|---|---|---|
| OAuth funciona | Token válido obtenido | Conexión exitosa |
| Sitio resuelto | site_id + drive_id obtenidos | API responde 200 |
| Documentos detectados | count > 0 | Listar biblioteca |
| Modo profesional: config generada | JSON válido para indexador | Parsear config |
| Modo local: descarga completa | files_downloaded = documents_found | Comparar conteos |
| Credenciales seguras | No en logs, no en plain text | Auditoría de output |
| Integración con indexer | Docs descargados son indexables | Ejecutar indexer sobre ellos |

---

## 5. Gestión de Errores

| Código Error | Condición | Recuperación | ¿Reintentar? |
|---|---|---|---|
| `AUTH_FAILED` | Credenciales incorrectas o expiradas | Re-ejecutar autenticación | Sí |
| `SITE_NOT_FOUND` | URL de sitio incorrecta | Verificar formato, listar sitios | No |
| `ACCESS_DENIED` | App sin permisos en el sitio | Instrucciones para admin de SharePoint | No |
| `DOWNLOAD_TIMEOUT` | Timeout descargando archivo grande | Retry con backoff | Sí (3 veces) |
| `QUOTA_GRAPH_API` | Rate limit de Microsoft Graph | Backoff exponencial | Sí (con delay) |
| `LIBRARY_EMPTY` | Biblioteca sin documentos | Verificar path/filtro | No |

---

## 6. Puntos de Integración

### Invocado Por
- Usuario directo (configurar SharePoint)
- `rag-onboarding` (como fuente adicional opcional)

### Invoca A
- Microsoft Graph API (resolución de sitio, listado, descarga)
- Azure AD / Entra ID (OAuth 2.0)
- `rag-indexer-specialist` (modo local: indexar después de descargar)
- `rag-storage-connector` (almacenar config de conexión)
- `rag-agent-instrumentation` (telemetría)

### Salida Consumida Por
- `rag-indexer-specialist` (docs descargados para indexar)
- Azure Search indexer (modo profesional: indexación directa)
- `rag-chat` (consulta sobre docs de SharePoint)

---

## 7. Restricciones

- OAuth tokens NUNCA en logs ni archivos no cifrados
- Respetar permisos de SharePoint (no acceder a lo que el usuario no puede ver)
- Modo local: crear carpeta con timestamp (no sobrescribir descargas previas)
- Modo profesional: no duplicar documentos en knowledge/ (Azure Search indexa directo)
- Rate limiting de Graph API: respetar headers Retry-After
- Solo sitios SharePoint corporativos (no OneDrive personal)

---

## 8. Preguntas Abiertas

- [x] ¿Dos modos o uno? → Dos: profesional (producción) y local (simplicidad)
- [x] ¿OAuth interactivo o service principal? → Ambos (usuario elige)
- [ ] ¿Sincronización incremental en modo local? (solo docs nuevos/modificados) → Fase 2
- [ ] ¿Soportar Teams channels como fuente? → Fase 2
- [ ] ¿Webhook para notificaciones de cambio? → Fase 2

---

## 9. Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-05-15 | Spec inicial aprobado |
