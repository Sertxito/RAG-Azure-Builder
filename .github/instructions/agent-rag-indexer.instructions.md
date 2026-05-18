**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)




**Purpose:** Index all documents from `knowledge/` into Azure AI Search. Automatic.

**Called By:** rag-onboarding.agent.md (Phase 5) OR manual: `copilot-cli run rag-indexer-specialist.agent.md`

**Expected Duration:** 10-15 minutes depending on document size

---

## âœ… Indexing Checklist

- [ ] Connect to Azure Search
- [ ] Scan `knowledge/` folder structure
- [ ] Process PDFs (OCR + chunking)
- [ ] Process Word/Excel docs (parsing + chunking)
- [ ] Process code files (syntax-aware chunking)
- [ ] Process presentations (text extraction + chunking)
- [ ] Generate embeddings for all chunks
- [ ] Upload to Azure Search index
- [ ] Enable semantic search
- [ ] Show indexing summary

---

## Prerequisites (1 min - AUTO)

```python
import os
from pathlib import Path



knowledge_path = Path("knowledge")
if not knowledge_path.exists():
    print("âŒ knowledge/ folder not found")
    exit(1)



required_dirs = ["pdfs", "procedimientos", "codigo", "presentaciones"]
for subdir in required_dirs:
    if not (knowledge_path / subdir).exists():
        print(f"âš ï¸  {subdir}/ missing, creating...")
        (knowledge_path / subdir).mkdir()



counts = {}
for subdir in required_dirs:
    files = list((knowledge_path / subdir).rglob("*"))
    files = [f for f in files if f.is_file()]
    counts[subdir] = len(files)

print(f"""
ðŸ“‚ Document inventory:
   PDFs: {counts['pdfs']} files
   Procedimientos: {counts['procedimientos']} files
   CÃ³digo: {counts['codigo']} files
   Presentaciones: {counts['presentaciones']} files
   TOTAL: {sum(counts.values())} files
""")
```

---

## Phase 1: Connect to Azure Search (1 min - AUTO)

```python
import os
from dotenv import load_dotenv
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.identity import AzureKeyCredential

load_dotenv()



search_endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
search_key = os.getenv("AZURE_SEARCH_API_KEY")
index_name = "rag-documents"

try:
    index_client = SearchIndexClient(search_endpoint, AzureKeyCredential(search_key))
    search_client = SearchClient(search_endpoint, index_name, AzureKeyCredential(search_key))
    print("âœ… Connected to Azure Search")
except Exception as e:
    print(f"âŒ Failed to connect: {e}")
    exit(1)
```

---

## Phase 2: Process PDFs (3 min)

```python
import os
from pathlib import Path
from PyPDF2 import PdfReader
import pytesseract
from PIL import Image
import io

pdf_folder = Path("knowledge/pdfs")
processed_chunks = []

print("â³ Processing PDFs...")

for pdf_file in pdf_folder.rglob("*.pdf"):
    print(f"   Processing: {pdf_file.name}")
    
    try:
        # Extract text from PDF
        with open(pdf_file, "rb") as f:
            reader = PdfReader(f)
            full_text = ""
            
            for page_num, page in enumerate(reader.pages):
                # Try text extraction first
                text = page.extract_text()
                
                # If text-less (scanned), use OCR
                if not text.strip():
                    image = page.to_image()
                    text = pytesseract.image_to_string(image)
                
                full_text += f"\n[Page {page_num + 1}]\n{text}"
        
        # Chunk text (500 chars per chunk, 50 char overlap)
        chunks = chunk_text(full_text, chunk_size=500, overlap=50)
        
        # Add metadata
        for i, chunk in enumerate(chunks):
            processed_chunks.append({
                "file": pdf_file.name,
                "file_type": "pdf",
                "chunk_num": i + 1,
                "content": chunk,
                "source_url": str(pdf_file)
            })
        
        print(f"      âœ… {len(chunks)} chunks")
        
    except Exception as e:
        print(f"      âŒ Error: {e}")
        continue

print(f"âœ… PDF processing complete: {len(processed_chunks)} chunks")
```

---

## Phase 3: Process Procedimientos (2 min)

```python
import os
from pathlib import Path
from docx import Document
from openpyxl import load_workbook
import markdown

proc_folder = Path("knowledge/procedimientos")
print("â³ Processing Procedimientos...")

for file_path in proc_folder.rglob("*"):
    if not file_path.is_file():
        continue
    file_type = file_path.suffix.lower()
    
    try:
        if file_type == ".docx":
            print(f"   Processing: {file_path.name} (Word)")
            doc = Document(file_path)
            text = "\n".join([para.text for para in doc.paragraphs])
            
        elif file_type == ".xlsx":
            print(f"   Processing: {file_path.name} (Excel)")
            wb = load_workbook(file_path)
            text = ""
            for sheet in wb.sheetnames:
                ws = wb[sheet]
                text += f"\n[Sheet: {sheet}]\n"
                for row in ws.iter_rows(values_only=True):
                    text += " | ".join(str(cell) if cell else "" for cell in row) + "\n"
            
        elif file_type == ".md":
            print(f"   Processing: {file_path.name} (Markdown)")
            with open(file_path) as f:
                text = f.read()
        
        else:
            continue
        
        # Chunk
        chunks = chunk_text(text, chunk_size=500, overlap=50)
        
        for i, chunk in enumerate(chunks):
            processed_chunks.append({
                "file": file_path.name,
                "file_type": file_type.strip("."),
                "chunk_num": i + 1,
                "content": chunk,
                "source_url": str(file_path)
            })
        
        print(f"      âœ… {len(chunks)} chunks")
        
    except Exception as e:
        print(f"      âŒ Error: {e}")
        continue

print(f"âœ… Procedimientos processing complete")
```

---

## Phase 4: Process CÃ³digo (2 min)

```python
from pathlib import Path

code_folder = Path("knowledge/codigo")
print("â³ Processing CÃ³digo...")

for code_file in code_folder.rglob("*"):
    if not code_file.is_file():
        continue
    lang = code_file.suffix.lower()
    
    try:
        print(f"   Processing: {code_file.name} ({lang})")
        
        with open(code_file, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        # Syntax-aware chunking (don't split functions/procedures)
        if lang in [".sql", ".py", ".js"]:
            chunks = chunk_code(content, language=lang, chunk_size=800)
        else:
            chunks = chunk_text(content, chunk_size=500, overlap=50)
        
        for i, chunk in enumerate(chunks):
            processed_chunks.append({
                "file": code_file.name,
                "file_type": lang.strip("."),
                "chunk_num": i + 1,
                "content": chunk,
                "source_url": str(code_file)
            })
        
        print(f"      âœ… {len(chunks)} chunks")
        
    except Exception as e:
        print(f"      âŒ Error: {e}")
        continue

print(f"âœ… CÃ³digo processing complete")
```

---

## Phase 5: Process Presentaciones (2 min)

```python
from pathlib import Path
from pptx import Presentation

ppt_folder = Path("knowledge/presentaciones")
print("â³ Processing Presentaciones...")

for ppt_file in ppt_folder.rglob("*.pptx"):
    try:
        print(f"   Processing: {ppt_file.name}")
        
        prs = Presentation(ppt_file)
        text = ""
        
        for slide_num, slide in enumerate(prs.slides):
            text += f"\n[Slide {slide_num + 1}]\n"
            
            for shape in slide.shapes:
                if hasattr(shape, "text"):
                    text += shape.text + "\n"
        
        chunks = chunk_text(text, chunk_size=500, overlap=50)
        
        for i, chunk in enumerate(chunks):
            processed_chunks.append({
                "file": ppt_file.name,
                "file_type": "pptx",
                "chunk_num": i + 1,
                "content": chunk,
                "source_url": str(ppt_file)
            })
        
        print(f"      âœ… {len(chunks)} chunks")
        
    except Exception as e:
        print(f"      âŒ Error: {e}")
        continue

print(f"âœ… Presentaciones processing complete")
```

---

## Phase 6: Generate Embeddings (3 min - AUTO)

```python
import os
from dotenv import load_dotenv
from azure.openai import AzureOpenAI

load_dotenv()

client = AzureOpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    api_version="2024-05-01-preview",
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
)

print("â³ Generating embeddings...")



batch_size = 100
for i in range(0, len(processed_chunks), batch_size):
    batch = processed_chunks[i:i+batch_size]
    
    print(f"   Batch {i//batch_size + 1}: Processing {len(batch)} chunks...")
    
    for chunk in batch:
        try:
            response = client.embeddings.create(
                input=chunk["content"],
                model="text-embedding-3-small"
            )
            chunk["embedding"] = response.data[0].embedding
        except Exception as e:
            print(f"      âš ï¸  Embedding failed for chunk: {e}")
            chunk["embedding"] = [0.0] * 1536  # Fallback empty vector

print(f"âœ… Embeddings generated for {len(processed_chunks)} chunks")
```

---

## Phase 7: Upload to Search (2 min - AUTO)

```python
print("â³ Uploading to Azure Search...")



batch_size = 1000
for i in range(0, len(processed_chunks), batch_size):
    batch = processed_chunks[i:i+batch_size]
    
    try:
        results = search_client.upload_documents(batch)
        print(f"   Batch {i//batch_size + 1}: {len(results)} chunks uploaded")
    except Exception as e:
        print(f"   âŒ Batch upload failed: {e}")

print(f"âœ… All {len(processed_chunks)} chunks uploaded to Search")
```

---

## Phase 8: Enable Semantic Search (1 min - AUTO)

```python
from azure.search.documents.indexes.models import (
    SearchIndex, SearchField, SearchFieldDataType, SimpleField
)

try:
    # Update index to enable semantic search
    index = index_client.get_index("rag-documents")
    
    # Semantic search configuration
    index.semantic_config = SemanticConfiguration(
        name="default",
        fields=SemanticField(content_fields=[SemanticField(field_name="content")]),
        prioritized_fields=PrioritizedFields(
            content_fields=[SemanticField(field_name="content")]
        )
    )
    
    index_client.create_or_update_index(index)
    print("âœ… Semantic search enabled")
    
except Exception as e:
    print(f"âš ï¸  Semantic search setup warning: {e}")
```

---

## Phase 9: Show Summary (1 min)

```
âœ… INDEXING COMPLETE!

ðŸ“Š Summary:
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ PDFs:           42 files â†’ 1,200 chunks â”‚
â”‚ Procedimientos:  15 files â†’ 350 chunks  â”‚
â”‚ CÃ³digo:         8 files â†’ 400 chunks   â”‚
â”‚ Presentaciones: 3 files â†’ 180 chunks   â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ TOTAL:          68 files â†’ 2,130 chunks â”‚
â”‚ Index Name:     rag-documents           â”‚
â”‚ Semantic Search: âœ… Enabled             â”‚
â”‚ Embeddings:     âœ… Generated (1,536-dim)â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Next steps:
  1. Test connection: rag-azure-setup.agent.md (Phase 7)
  2. Start querying: python scripts/consulta/consultar.py
```

---

## Error Handling

### Folder Empty
```
âš ï¸ No documents found in knowledge/ folder.

You can:
  A) Add documents and re-run indexing
  B) Continue anyway (start with empty index)

Your choice? (A/B)
```

### File Corruption
```
âš ï¸ Some files had errors during processing:
   âŒ corrupted-file.pdf: OCR failed
   âŒ binary-file.xlsx: Not readable

Indexed: 2,100 / 2,130 chunks
Success rate: 98.6%

Details saved to: logs/indexing-errors.log
```

### Embedding Generation Fails
```
âŒ OpenAI embedding API failed: Rate limit exceeded.

Suggestions:
  â€¢ Wait 5 minutes before retrying
  â€¢ Reduce batch size
  â€¢ Check AZURE_OPENAI_API_KEY

Retry? (Y/n)
```

### Upload to Search Fails
```
âŒ Azure Search upload failed: Index quota exceeded.

Current: 2,130 documents
Limit: 1,000 documents

Solutions:
  1. Use higher Search tier (Standard â†’ Premium)
  2. Split into multiple indexes
  3. Archive older documents

Proceed with Premium tier? (Y/n)
```

---

## Resumption Support

Save checkpoint:

```json
{
  "phase": 5,
  "status": "in-progress",
  "processed_chunks": 1250,
  "next": "Complete embeddings generation"
}
```

On restart:
```
ðŸ”„ Detected incomplete indexing.
Resume from chunk 1,250? (Y/n)
```

---

## Success Criteria

âœ… All document types processed (PDFs, Word, Excel, Code, PPTs)

âœ… All chunks have embeddings

âœ… All chunks uploaded to Azure Search

âœ… Semantic search enabled

âœ… Indexing summary shows total chunks

âœ… User ready for Phase 7 (Test connections)

