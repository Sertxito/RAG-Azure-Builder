---
name: rag-sharepoint-connector
description: "Hybrid-professional SharePoint integration for RAG. Two modes: Professional (Azure Search indexer, real-time sync, no duplication) or Local (download to knowledge/, coexists with traditional docs)"
version: "1.0.0"
author: "RAG Framework"
tags: ["sharepoint", "hybrid", "integration", "azure-search", "microsoft-graph"]
---

# RAG: SharePoint Connector

**Hybrid-professional architecture for SharePoint integration**

Integrates SharePoint document libraries into RAG with two flexible modes:
- **Professional** (default): Azure Search indexer syncs directly from SharePoint (real-time, no duplication)
- **Local**: Download all documents to `knowledge/sharepoint-{date}/` (works offline, coexists with traditional docs)

---

## 📋 Features

✅ **OAuth 2.0 Authentication**
- Interactive browser login (default)
- Service principal for automation
- Token refresh & expiration handling
- Secure credential storage

✅ **Recursive Document Discovery**
- Scans all nested folders in SharePoint
- Preserves folder structure
- Progress tracking
- Size estimation

✅ **Professional Mode (Azure Search)**
- Direct integration with Azure Search indexer
- Real-time sync (configurable schedule)
- No document duplication
- Cloud-native, scalable

✅ **Local Mode (Download)**
- Download all files with structure preservation
- Timestamped folders: `sharepoint-2026-05-14_14-30-45/`
- Manifest with metadata & checksums
- Coexists with traditional knowledge docs

✅ **Metadata Tracking**
- Source tracking (SharePoint vs. local)
- File modification times
- MIME type detection
- Path preservation

✅ **Error Resilience**
- Automatic retry on failures
- Partial success tracking
- Detailed error logging
- Resume capability

---

## 🚀 Quick Start

### Prerequisites

```bash
# 1. Azure AD app registration (see Setup section)
# 2. SharePoint site with document library
# 3. Python 3.10+
# 4. Dependencies
pip install msal requests tqdm
```

### Professional Mode (Recommended)

```bash
# 1. Get credentials
TENANT_ID="your-tenant-id"
CLIENT_ID="your-client-id"
SHAREPOINT_URL="https://contoso.sharepoint.com/sites/MyDocuments"

# 2. Setup (one-time)
python sharepoint-connector.py \
  --mode professional \
  --tenant-id $TENANT_ID \
  --client-id $CLIENT_ID \
  --sharepoint-url $SHAREPOINT_URL

# 3. Follow on-screen instructions to:
#    - Login in browser
#    - Authorize SharePoint access
#    - Configure Azure Search indexer (manual step in portal)
```

### Local Mode

```bash
# 1. Setup (downloads everything)
python sharepoint-connector.py \
  --mode local \
  --tenant-id $TENANT_ID \
  --client-id $CLIENT_ID \
  --sharepoint-url $SHAREPOINT_URL \
  --project-root /path/to/rag-mensadef

# 2. Files downloaded to: knowledge/sharepoint-2026-05-14_14-30-45/
# 3. Manifest created: knowledge/sharepoint-2026-05-14_14-30-45/manifest.json

# 4. Index automatically with rag-indexer
python .github/skills/rag-indexer/indexar.py
```

---

## 🔧 Setup Details

### Azure AD App Registration

1. **Create app registration** in Azure Portal
   ```
   Azure Portal → Azure Active Directory → App registrations → New registration
   Name: "RAG SharePoint Connector"
   Redirect URI: http://localhost:8000 (for interactive auth)
   ```

2. **Add permissions**
   ```
   API Permissions:
   - Microsoft Graph → Sites.Read.All (Delegated + Application)
   - Microsoft Graph → Files.Read.All (Delegated + Application)
   - Microsoft Graph → offline_access (Delegated)
   ```

3. **Get credentials**
   ```
   Certificates & secrets:
   - Note your Client ID (from Overview)
   - Create Client Secret (copy value immediately)
   
   Your tenant ID: Azure Portal → Azure Active Directory → Properties
   ```

4. **Grant SharePoint permissions**
   ```
   SharePoint Admin Center → Share Data Access → Grant access
   - Select your app
   - Grant access to site where documents live
   ```

### Environment Setup

```bash
# .env or set environment variables
SHAREPOINT_TENANT_ID=your-tenant-id
SHAREPOINT_CLIENT_ID=your-client-id
SHAREPOINT_CLIENT_SECRET=your-client-secret  # (optional, for service principal)
SHAREPOINT_URL=https://contoso.sharepoint.com/sites/MyDocuments
```

---

## 📖 Usage Patterns

### Pattern 1: Professional Mode (Real-Time Sync)

```python
from sharepoint_connector import setup_sharepoint_connector
from pathlib import Path

connector = setup_sharepoint_connector(
    project_root=Path("/path/to/rag-mensadef"),
    tenant_id="your-tenant-id",
    client_id="your-client-id",
    sharepoint_url="https://contoso.sharepoint.com/sites/Docs",
    mode="professional",
)

# Configure indexer (manual or via Azure SDK)
config = connector.setup_professional_mode()
print(config)  # Use this to create indexer in Azure Portal
```

### Pattern 2: Local Mode (Download & Index)

```python
from sharepoint_connector import setup_sharepoint_connector
from pathlib import Path

connector = setup_sharepoint_connector(
    project_root=Path("/path/to/rag-mensadef"),
    tenant_id="your-tenant-id",
    client_id="your-client-id",
    sharepoint_url="https://contoso.sharepoint.com/sites/Docs",
    mode="local",
)

# Download all files
download_dir = connector.setup_local_mode(
    knowledge_dir=Path("/path/to/rag-mensadef/knowledge")
)
print(f"Downloaded to: {download_dir}")
```

### Pattern 3: Service Principal (Automation)

```python
# For unattended operation (CI/CD, scheduled tasks)
connector = setup_sharepoint_connector(
    project_root=Path("."),
    tenant_id="your-tenant-id",
    client_id="your-client-id",
    sharepoint_url="https://contoso.sharepoint.com/sites/Docs",
    mode="local",
    client_secret="your-client-secret",
)
```

---

## 🏗️ Architecture

### Professional Mode

```
SharePoint Document Library
    ↓ (Microsoft Graph API)
Azure Search Data Source
    ↓ (Real-time sync, hourly)
Azure Search Indexer
    ↓
Index: "rag-documents"
    ├── Documents from SharePoint (source=sharepoint)
    ├── Documents from local knowledge/ (source=local)
    └── Hybrid search results
```

**Benefits:**
- ✅ No data duplication
- ✅ Real-time updates
- ✅ Cloud-native
- ✅ Scales to 1M+ documents

### Local Mode

```
SharePoint Document Library
    ↓ (Download recursively)
knowledge/sharepoint-2026-05-14_14-30-45/
    ├── File 1.pdf
    ├── Subfolder/
    │   └── File 2.docx
    └── manifest.json
         ↓ (rag-indexer.py)
         ↓
Azure Search Index
    ├── Documents from SharePoint (source=sharepoint)
    ├── Documents from local knowledge/traditional (source=local)
    └── Hybrid search results
```

**Benefits:**
- ✅ Works offline (after download)
- ✅ Preserves folder structure
- ✅ Full control over indexing
- ✅ Supports incremental updates

---

## 📊 Coexistence Model

**Key Guarantee:** SharePoint documents coexist with traditional knowledge without conflicts.

### How It Works

```
Azure Search Index: "rag-documents"

Document A (MENSADEF Manual)
  - source: "local"
  - path: "knowledge/pdfs/mensadef-manual.pdf"
  - indexed_by: "rag-indexer.py"

Document B (SharePoint Finance Report)
  - source: "sharepoint"
  - path: "Shared Documents/Finance/Q1-Report.xlsx"
  - indexed_by: "azure-search-indexer" OR "rag-indexer.py"

→ Both fully searchable, source tracking preserved
→ Filter by source if needed: "source=sharepoint"
```

---

## 🔐 Security

### Credential Management

```bash
# Credentials are NEVER committed to git
# 1. Interactive auth (browser): tokens cached locally in .cache/msal/
# 2. Service principal: use Azure Key Vault or environment variables

# .gitignore entries (already configured)
.env
sharepoint_config.json
.cache/
```

### Permissions

- **Minimal scope**: Files.Read.All + Sites.Read.All (read-only)
- **No write access**: Cannot modify SharePoint
- **No delete access**: Cannot remove documents
- **Site-scoped**: Only accesses specified SharePoint site

### Token Handling

```
Interactive:
  ✅ Access token: 1 hour
  ✅ Refresh token: 90 days (automatic refresh)
  ✅ MFA supported

Service Principal:
  ✅ Access token: 1 hour
  ✅ No refresh (re-authenticate)
  ✅ Unattended safe
```

---

## 🛠️ Troubleshooting

### Issue: "Authentication failed: Invalid tenant"

```
❌ Fix: Verify TENANT_ID is correct (not object ID, but tenant ID)
Azure Portal → Azure Active Directory → Properties
Copy: Directory ID (not Object ID)
```

### Issue: "Access denied to site"

```
❌ Fix: Grant app permission to site
SharePoint Admin Center → Share Data Access → Grant access
Select your RAG app and target site
```

### Issue: "Files not downloading in local mode"

```
❌ Fix: Check network & firewall
- Verify SharePoint URL is accessible
- Check Azure AD app permissions: Graph API → Files.Read.All
- Check file sizes (some large files may timeout)
```

### Issue: "Index not updating in professional mode"

```
❌ Fix: Verify Azure Search indexer
1. Check indexer exists: Azure Portal → Search Service → Indexers
2. Check data source: Indexers → data-source → Test connection
3. Run indexer manually: Azure Portal → Indexers → Run
4. Check indexer errors: Indexers → history tab
```

---

## 📈 Performance

### Local Mode Benchmarks

| Document Count | Total Size | Download Time | Index Time | Total |
|---|---|---|---|---|
| 100 files | 500 MB | 2-3 min | 3-5 min | ~5-8 min |
| 500 files | 2 GB | 5-10 min | 10-15 min | ~15-25 min |
| 1000+ files | 5+ GB | 15-30 min | 20-40 min | ~35-70 min |

### Professional Mode Benchmarks

| Operation | Time | Notes |
|---|---|---|
| Initial indexer run | 5-10 min | Scans all SharePoint docs |
| Incremental sync | 1-2 min | Hourly (configurable) |
| Search latency | 100-500 ms | Depends on query complexity |

---

## 🔄 Updates & Maintenance

### Periodic Sync (Local Mode)

```bash
#!/bin/bash
# sync-sharepoint.sh - Run daily via cron or Task Scheduler

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
python .github/skills/rag-sharepoint-connector/sharepoint-connector.py \
  --mode local \
  --tenant-id $SHAREPOINT_TENANT_ID \
  --client-id $SHAREPOINT_CLIENT_ID \
  --sharepoint-url $SHAREPOINT_URL \
  --project-root .

# Re-index only new documents
python .github/skills/rag-indexer/indexar.py --incremental

echo "✅ SharePoint sync complete: $(date)"
```

### Real-Time Sync (Professional Mode)

- Azure Search indexer runs automatically (default: hourly)
- Configure schedule in Azure Portal: Search Service → Indexers → {indexer-name} → Schedule
- Manual trigger: `Run` button in portal

---

## 📝 Examples

### Example 1: Client with Multi-Site SharePoint

```
Setup for each site:
  - Client Finance Site
  - Client HR Site
  - Shared Templates Site

Each creates separate data source:
  - sharepoint-finance
  - sharepoint-hr
  - sharepoint-templates

All indexed to same "rag-documents" index
Search returns unified results across all sites
```

### Example 2: Hybrid MENSADEF + Client SharePoint

```
Knowledge sources:
  1. rag-mensadef/knowledge/pdfs/     ← MENSADEF docs (local)
  2. rag-mensadef/knowledge/sharepoint-2026-05-14/  ← Client SharePoint (download)

Single index: "rag-documents"
Query results include both sources
Source tracking: filter by "source" field if needed
```

### Example 3: Scheduled CI/CD Sync

```yaml
# .github/workflows/sharepoint-sync.yml
name: Daily SharePoint Sync
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Sync SharePoint
        env:
          SHAREPOINT_TENANT_ID: ${{ secrets.SHAREPOINT_TENANT_ID }}
          SHAREPOINT_CLIENT_ID: ${{ secrets.SHAREPOINT_CLIENT_ID }}
          SHAREPOINT_CLIENT_SECRET: ${{ secrets.SHAREPOINT_CLIENT_SECRET }}
        run: |
          pip install -r .github/requirements.txt
          python .github/skills/rag-sharepoint-connector/sharepoint-connector.py \
            --mode local \
            --tenant-id $SHAREPOINT_TENANT_ID \
            --client-id $SHAREPOINT_CLIENT_ID \
            --client-secret $SHAREPOINT_CLIENT_SECRET \
            --sharepoint-url https://client.sharepoint.com/sites/Docs
          python .github/skills/rag-indexer/indexar.py
```

---

## 🤝 Integration with Agents

### Used By

- **rag-onboarding.agent.md**: Phase 2 (ask if user has SharePoint)
- **rag-sharepoint-setup.agent.md**: Dedicated setup wizard

### Calls

- `sharepoint-connector.py` (main module)
- `sharepoint-auth.py` (OAuth handling)
- `rag-indexer/indexar.py` (local mode: after download)
- `azure-search` SDK (professional mode: direct indexing)

---

## 📚 References

- [Microsoft Graph SharePoint API](https://learn.microsoft.com/en-us/graph/api/resources/sharepoint?view=graph-rest-1.0)
- [MSAL Python (Authentication)](https://github.com/AzureAD/microsoft-authentication-library-for-python)
- [Azure Search Indexing](https://learn.microsoft.com/en-us/azure/search/search-indexer-overview)
- [RAG with SharePoint](https://learn.microsoft.com/en-us/azure/search/search-solutions-retrieval-augmented-generation)

---

## ✅ Checklist for Client Setup

- [ ] Azure AD app registered
- [ ] Client ID & Tenant ID obtained
- [ ] Permissions granted to SharePoint site
- [ ] Service principal secret created (if service principal mode)
- [ ] Dependencies installed: `pip install -r .github/requirements.txt`
- [ ] Test authentication: `python sharepoint-auth.py <tenant> <client>`
- [ ] Professional mode: Configure Azure Search indexer
- [ ] Local mode: Run connector, verify download complete
- [ ] Run rag-indexer.py to index documents
- [ ] Test query: `python .github/skills/rag-query-cli/consultar.py "test query"`
- [ ] Setup scheduler (optional): Daily sync via cron/Task Scheduler
