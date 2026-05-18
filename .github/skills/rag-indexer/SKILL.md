# RAG Indexer — Document Indexing

**Index documents from `knowledge/` folder into Azure AI Search.**

## Overview

Bulk-indexes documents from various formats (PDF, DOCX, SQL, TXT, MD) into Azure AI Search with automatic chunking and metadata extraction.

## Features

- ✅ Multi-format support (PDF, DOCX, SQL, TXT, MD, XML)
- ✅ Automatic text chunking with overlap
- ✅ Index creation if not exists
- ✅ Error handling and reporting
- ✅ Progress tracking
- ✅ Relative path support

## Requirements

- Azure AI Search instance
- `.env` file with:
  - `AZURE_SEARCH_ENDPOINT`
  - `AZURE_SEARCH_KEY`
  - `AZURE_SEARCH_INDEX`
- `knowledge/` folder structure:
  ```
  knowledge/
  ├── pdfs/
  ├── procedimientos/
  ├── codigo/
  └── presentaciones/
  ```

## Installation

```bash
pip install -r .github/requirements.txt
```

## Usage

### Run Indexing

```bash
# From project root
python .github/skills/rag-indexer/indexar.py
```

### What It Does

1. **Creates index** if doesn't exist
2. **Scans folders**:
   - `knowledge/pdfs/` → PDF documents
   - `knowledge/procedimientos/` → Word/Excel/Markdown
   - `knowledge/codigo/` → SQL/Python/JavaScript
   - `knowledge/presentaciones/` → PowerPoint/Images
3. **Extracts text** from each file
4. **Chunks text** (1000 tokens, 200 token overlap)
5. **Uploads to Azure** with metadata
6. **Reports summary**

### Output Example

```
============================================================
  RAG Indexer - Indexing Documents
============================================================

✅ Index 'rag-documents' already exists

🔍 Starting indexation...

📂 Indexing pdf from pdfs/
  ✅ Manual.pdf (8 chunks)
  ✅ FAQ.pdf (12 chunks)
  Total: 2 files indexed

📂 Indexing document from procedimientos/
  ✅ Process.docx (5 chunks)
  ✅ Checklist.xlsx (3 chunks)
  Total: 2 files indexed

📂 Indexing code from codigo/
  ✅ schema.sql (15 chunks)
  Total: 1 files indexed

📂 Indexing presentation from presentaciones/
  ✅ Architecture.pptx (4 chunks)
  Total: 1 file indexed

============================================================
  Indexation Summary
============================================================
✅ Total files processed: 6
✅ Total documents indexed: 6
✅ Total chunks created: 47

✅ Indexation complete! Ready to query.
============================================================
```

## Chunking Strategy

- **Chunk size**: 1000 tokens
- **Overlap**: 200 tokens (for context continuity)
- **Format**: Preserves structure, removes noise
- **Metadata**: File path, chunk ID, creation timestamp

## Supported Formats

| Format | Processor | Use Case |
|---|---|---|
| `.pdf` | PyPDF2 | Manuals, reports |
| `.docx` | python-docx | Procedures, guides |
| `.xlsx` | openpyxl | Checklists, data |
| `.sql` | Text reader | Database schemas |
| `.py/.js` | Text reader | Code documentation |
| `.txt/.md` | Text reader | Plain text docs |
| `.xml` | Text reader | Configuration |

## API

```python
from indexar import RAGIndexer

indexer = RAGIndexer()

# Create index if needed
indexer.ensure_index_exists()

# Index specific directory
indexer.index_directory(
    Path("knowledge/pdfs"),
    source_type="pdf",
    pattern="*.pdf"
)

# Get statistics
print(indexer.stats)
```

## Troubleshooting

| Issue | Solution |
|---|---|
| `No Azure credentials` | Check `.env` file |
| `knowledge/ not found` | Run from project root where `knowledge/` exists |
| `PDF extract errors` | Scanned PDFs (images) need OCR |
| `DOCX/XLSX not reading` | Verify file isn't corrupted or password-protected |

## Performance

- Small project (50 docs, ~10MB): ~5-10 seconds
- Medium project (500 docs, ~100MB): ~30-60 seconds
- Large project (5000+ docs): Consider batching

## Re-indexing

To re-index after adding new documents:

```bash
# Just run again—new docs are added, existing are updated
python .github/skills/rag-indexer/indexar.py
```

## Related Skills

- [`rag-query-cli`](../rag-query-cli/SKILL.md) — Query indexed documents
- [`rag-diagnostics`](../rag-diagnostics/SKILL.md) — Check index health

## See Also

- [.github/STANDALONE_GUIDE.md](../../STANDALONE_GUIDE.md) — Full setup workflow
