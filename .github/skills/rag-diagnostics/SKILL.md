# RAG Diagnostics — System Health & Monitoring

**Monitor, diagnose, and troubleshoot your RAG system.**

## Overview

Collection of diagnostic and monitoring tools to check Azure AI Search health, index status, and system configuration.

## Features

- ✅ System status report (all components)
- ✅ Index diagnostics (documents, fields, health)
- ✅ Configuration verification
- ✅ Real-time monitoring
- ✅ Error reporting with solutions

## Tools Included

### 1. **estado-sistema.py** — Full System Status

Check overall RAG health and component status.

```bash
python .github/skills/rag-diagnostics/estado-sistema.py
```

**Output:**
```
========================================================================
🚀 RAG SYSTEM STATUS REPORT
========================================================================

📍 PHASE 1: Keyword + Semantic Search
   Status: Running
   Items processed: 113
   Items failed: 0
   Duration: 245000 ms
   Index: rag-documents

📍 PHASE 2: Vector Search
   Status: Running
   Items processed: 86
   Items failed: 0
   Duration: 123000 ms
   Index: rag-documents-vectors

📊 INDEX STATISTICS
   ✓ rag-documents: 113 documents
   ✓ rag-documents-vectors: 86 documents
```

### 2. **diagnosticar.py** — Detailed Diagnostics

Deep dive into Azure Search configuration and issues.

```bash
python .github/skills/rag-diagnostics/diagnosticar.py
```

**Output:**
```
1️⃣  INDEXES
   ✅ rag-documents
      - Campos: 7
      - Vectores: ❌

2️⃣  DATA SOURCES
   ✅ blob-storage
      - Tipo: AzureBlobStorage

3️⃣  SKILLSETS
   ✅ ocr-skillset
      - Skills: 4
      - Tipos: OcrSkill, SplitSkill, MergeSkill

4️⃣  INDEXERS
   ✅ blob-indexer
      - Estado: Running
      - Schedule: Every hour
```

### 3. **monitorear.py** — Real-Time Monitoring

Continuous monitoring of indexer activity.

```bash
python .github/skills/rag-diagnostics/monitorear.py
```

**Output:**
```
Monitoring indexer: blob-indexer
Press Ctrl+C to stop

[14:23:45] Status: Running | Processed: 45 | Failed: 0
[14:24:10] Status: Running | Processed: 89 | Failed: 1
[14:24:35] Status: Completed | Processed: 113 | Failed: 0
```

## Requirements

```bash
pip install -r .github/requirements.txt
```

- `.env` with Azure Search credentials:
  - `AZURE_SEARCH_ENDPOINT`
  - `AZURE_SEARCH_KEY`

## Usage Examples

### Check System Health

```bash
python .github/skills/rag-diagnostics/estado-sistema.py
```

### Diagnose Indexer Issues

```bash
python .github/skills/rag-diagnostics/diagnosticar.py
```

### Monitor Live Progress

```bash
# Watch indexing in real-time
python .github/skills/rag-diagnostics/monitorear.py
```

## Common Issues & Solutions

| Issue | Diagnosis | Solution |
|---|---|---|
| Index empty | `estado-sistema.py` shows 0 docs | Run `rag-indexer` skill |
| Indexer failed | `diagnosticar.py` shows status: Failed | Check `.env` credentials |
| Semantic search not working | Index missing semantic config | Recreate index with semantic enabled |
| Slow indexing | `monitorear.py` shows low throughput | Increase Search tier or batch size |

## Integration

### In Scripts

```python
from estado_sistema import check_status

status = check_status()
if status['index_count'] == 0:
    print("❌ No documents indexed yet")
else:
    print(f"✅ {status['index_count']} documents ready")
```

### In CI/CD

```bash
# Health check before deployment
python .github/skills/rag-diagnostics/diagnosticar.py || exit 1
```

## Performance Monitoring

Use `monitorear.py` to track:
- Indexer throughput
- Error rates
- Processing time
- System load

## Related Skills

- [`rag-indexer`](../rag-indexer/SKILL.md) — Index documents
- [`rag-query-cli`](../rag-query-cli/SKILL.md) — Query system
- [`rag-api-server`](../rag-api-server/SKILL.md) — REST endpoints

## See Also

- [.github/README.md](../../README.md) — Architecture overview
