---
name: 'RAG: SharePoint Setup'
description: 'Configure SharePoint integration with professional (Azure Search real-time) or local (download) mode. Handles OAuth setup, site resolution, and indexer configuration.'
model: 'claude-haiku-4.5'
tools: true
skills: ['rag-sharepoint-connector', 'rag-indexer', 'rag-agent-instrumentation']
depends_on: ['rag-azure-setup']
---

**RAG Reference:** [Retrieval-augmented Generation with SharePoint - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/search-solutions-retrieval-augmented-generation)

## Purpose

Complete SharePoint integration setup **in one shot**:

- ✅ OAuth 2.0 authentication (browser or service principal)
- ✅ SharePoint site discovery
- ✅ Choose mode: Professional (real-time sync) or Local (download)
- ✅ Configure for your use case
- ✅ Validate connection
- ✅ Ready to query

---

## When to Use

- `Setup SharePoint for RAG`
- `Connect RAG to SharePoint`
- `Configure SharePoint integration`
- `Hybrid knowledge sources`
- `Add SharePoint documents to RAG`

---

## Prerequisites

- ✅ Azure subscription with RAG infrastructure deployed
- ✅ SharePoint site with document library
- ✅ Azure AD app registration (see skill docs for setup)
- ✅ Admin access to SharePoint site
- ✅ Python 3.10+ with dependencies installed

---

## Expected Duration

- **Professional Mode**: ~5 minutes (setup) + manual Azure portal config (~10 min)
- **Local Mode**: ~5 minutes (setup) + download time (varies by document size)

---

## What This Agent Does

### Phase 1: Interview (1 min)

```
Questions:
  1. Have you registered an app in Azure AD? (Y/n)
  2. Which mode? (professional/local/auto-recommend)
  3. SharePoint URL? (https://contoso.sharepoint.com/sites/Docs)
  4. Tenant ID? (from Azure AD)
  5. Client ID? (from app registration)
  6. Client Secret? (optional, for service principal)
```

### Phase 2: OAuth Setup (2 min)

- **Option A** (Interactive): Browser login
  - Click link → login → authorize
  - Tokens cached automatically
  
- **Option B** (Service Principal): Unattended auth
  - Use client secret
  - No user interaction

### Phase 3: Site Resolution (1 min)

- Verify SharePoint site exists
- Detect document library
- Get site ID and drive ID
- Confirm folder structure

### Phase 4: Mode Configuration (1 min)

**Professional Mode:**
  - Show Azure Search indexer template
  - Instructions for manual setup in portal
  - Explain real-time sync schedule
  
**Local Mode:**
  - Start download
  - Show progress bar
  - Verify all files downloaded

### Phase 5: Validation (1 min)

- Test SharePoint connection
- Count documents found
- Verify credentials stored securely
- Show next steps

---

## Detailed Agent Behavior

### Workflow

```python
Agent: RAG-SharePoint-Setup
├─ Ask: Azure AD app registered?
│  └─ If no: Link to setup guide
│
├─ Ask: Setup mode?
│  ├─ Professional (recommend if Enterprise, large docs)
│  ├─ Local (recommend if small/medium, offline access needed)
│  └─ Auto-recommend based on project size
│
├─ Get credentials:
│  ├─ Ask: Tenant ID
│  ├─ Ask: Client ID
│  ├─ Ask: Client Secret? (optional)
│  └─ Ask: SharePoint URL
│
├─ Authenticate:
│  ├─ If service principal: Use client secret
│  ├─ If interactive: Open browser
│  └─ Verify: "✅ Authentication successful"
│
├─ Resolve site:
│  ├─ Verify URL exists
│  ├─ Get site ID
│  ├─ Get drive ID
│  └─ Show: "Site: Finance Documents (2,345 items)"
│
├─ Setup mode:
│  ├─ Professional:
│  │  ├─ Generate indexer config
│  │  ├─ Show: "Create indexer in portal using this config"
│  │  ├─ Link: "Open Azure Search Indexers"
│  │  └─ Wait: User confirms indexer created
│  │
│  └─ Local:
│     ├─ Create knowledge/sharepoint-{date}/
│     ├─ Download all files (progress bar)
│     ├─ Show: "Downloaded: 2,345 files, 15.3 GB"
│     └─ Ask: "Index now?"
│
├─ Post-setup:
│  ├─ If Local mode: Run rag-indexer.py
│  ├─ Save config to scripts/sharepoint-config.json
│  ├─ Update .env with SharePoint settings
│  └─ Show: "✅ Ready to query SharePoint documents"
│
└─ Next steps:
   ├─ Professional: "1. Setup indexer completed. Configure in Azure Portal."
   ├─ Local: "1. Documents indexed in Azure Search. Try querying."
   └─ "2. Run: python .github/skills/rag-query-cli/consultar.py 'your question'"
```

---

## Output

### Success Output

```
✅ SharePoint Setup Complete

Mode: Professional
SharePoint Site: Finance Documents
Documents found: 2,345
Total size: 15.3 GB

Next Steps:
1. Create indexer in Azure Portal
2. Use this configuration: [config.json]
3. Run indexer manually or wait for scheduled sync (1 hour)
4. Query documents: python consultar.py "..."

Config saved: scripts/sharepoint-config.json
```

### With Local Mode Download

```
✅ SharePoint Setup Complete

Mode: Local (Download)
SharePoint Site: Finance Documents
Downloaded: 2,345 files, 15.3 GB
Destination: knowledge/sharepoint-2026-05-14_14-30-45/

Indexing: Running rag-indexer.py...
  ✅ Indexed 2,345 documents
  ✅ Index size: 1.2 GB (compressed)

Next Steps:
1. Query: python .github/skills/rag-query-cli/consultar.py "What is the Q1 budget?"
2. Or: python .github/skills/rag-api-server/servidor-api.py (REST API)
3. Monitor: python .github/skills/rag-diagnostics/estado-sistema.py

Config saved: scripts/sharepoint-config.json
Manifest saved: knowledge/sharepoint-2026-05-14_14-30-45/manifest.json
```

---

## Skill Invocations

This agent uses:

- **sharepoint-connector.py**
  - OAuth authentication
  - Site resolution
  - Mode-specific setup
  
- **rag-indexer.py** (local mode only)
  - Index downloaded documents
  
- **rag-agent-instrumentation**
  - Track setup metrics
  - Log errors to Application Insights

---

## Error Handling

| Error | Recovery |
|-------|----------|
| "Authentication failed" | Rerun with correct credentials, check app registration |
| "Access denied to site" | Grant app permission in SharePoint Admin Center |
| "Site not found" | Verify URL format, check site exists, verify permissions |
| "Download timeout" | Retry, check network, consider chunked download |
| "Index already exists" | Confirm mode (professional: merge, local: new folder) |

---

## Related Skills

- **rag-azure-setup**: Deploy Azure infrastructure (prerequisite)
- **rag-indexer**: Index downloaded documents (local mode)
- **rag-query-cli**: Query all documents (SharePoint + local)
- **rag-diagnostics**: Monitor indexing progress

---

## FAQ

**Q: Which mode should I use?**
- **Professional**: Large enterprise SharePoint, frequent updates, don't need offline access → Real-time sync, no duplication
- **Local**: Smaller docs, want full control, need offline access → Download once, works anywhere

**Q: Can I use both modes?**
- Yes! Professional for real-time critical docs, Local for backup or specific folders

**Q: What about existing knowledge/ documents?**
- Both coexist perfectly. Same index, different source metadata. Search returns both.

**Q: How often does professional mode sync?**
- Default: Hourly. Configurable in Azure Portal Indexer settings.

**Q: Can I schedule local mode downloads?**
- Yes! Setup cron job or Windows Task Scheduler (see SKILL.md examples)
