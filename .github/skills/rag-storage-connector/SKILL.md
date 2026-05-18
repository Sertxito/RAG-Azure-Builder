# RAG Storage Connector — Azure Blob Integration

**PowerShell-based helper for Azure Blob Storage credentials.**

> ℹ️ This skill is **PowerShell-only** (no Python). It's a thin helper for fetching
> connection strings via Azure CLI. Document indexing/upload happens in `rag-indexer`
> (which can read from local folders or, with credentials from here, from Blob).

## Overview

Helper utilities for Azure Blob Storage integration, used by indexers and document upload pipelines.

## Features

- ✅ Connection string management
- ✅ Account/container listing
- ✅ PowerShell/Bash compatibility
- ✅ Credential helpers

## Requirements

- Azure Storage account
- `.env` or Azure CLI credentials

## Usage

### Get Connection String (PowerShell)

```powershell
# From project root
. .github/skills/rag-storage-connector/conexion-storage.ps1

# This outputs connection string to paste into .env
```

### In Environment

Add to `.env`:
```
AZURE_STORAGE_ACCOUNT=mystorageaccount
AZURE_STORAGE_KEY=<key-from-above>
AZURE_STORAGE_CONTAINER=documents
```

## Related Skills

- [`rag-indexer`](../rag-indexer/SKILL.md) — Uses storage for document sources
- [`rag-api-server`](../rag-api-server/SKILL.md) — Upload endpoint

## See Also

- [.github/README.md](../../README.md) — Architecture
