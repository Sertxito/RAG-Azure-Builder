# RAG SharePoint Connector

Hybrid-professional SharePoint integration for RAG.

## Files

- **sharepoint-auth.py**: OAuth 2.0 authentication (interactive + service principal)
- **sharepoint-connector.py**: Main logic (professional + local modes)
- **SKILL.md**: Complete documentation

## Quick Start

```bash
# Professional mode (recommended)
python sharepoint-connector.py \
  --mode professional \
  --tenant-id <your-tenant-id> \
  --client-id <your-client-id> \
  --sharepoint-url "https://contoso.sharepoint.com/sites/Docs"

# Local mode (download)
python sharepoint-connector.py \
  --mode local \
  --tenant-id <your-tenant-id> \
  --client-id <your-client-id> \
  --sharepoint-url "https://contoso.sharepoint.com/sites/Docs" \
  --project-root /path/to/rag-mensadef
```

## Modes

### Professional (Default)

- Azure Search indexer syncs from SharePoint
- Real-time updates (hourly)
- No document duplication
- Enterprise-grade

### Local

- Download all SharePoint docs
- Works offline after download
- Coexists with traditional knowledge/
- Full control over indexing

## See Also

- [SKILL.md](./SKILL.md) - Full documentation
- [sharepoint-auth.py](./sharepoint-auth.py) - OAuth implementation
- [sharepoint-connector.py](./sharepoint-connector.py) - Main connector
