**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)




**Purpose:** Fully automated wizard for new users. Setup â†’ Deploy â†’ Index â†’ Ready.

**User Entry:** `copilot-cli run .github/agents/rag-onboarding.agent.md`

**Expected Duration:** ~30 minutes total (fully automatic)

---

## ✅ MUST-DO Checklist

- [ ] Preguntar nombre del proyecto → crear `rag-{nombre}/`
- [ ] Crear estructura de carpetas dentro de `rag-{nombre}/`
- [ ] Entrevistar al usuario (5 preguntas)
- [ ] Recomendar configuración según tamaño de docs
- [ ] Validar costes ANTES de desplegar
- [ ] Desplegar infraestructura Azure (Bicep)
- [ ] Indexar todos los documentos de `knowledge/`
- [ ] Generar `.env` con credenciales
- [ ] Probar todas las conexiones
- [ ] Mostrar instrucciones de uso (3 modos)
- [ ] Guardar resumen en `outputs/`

---

## Phase-by-Phase Automation

### Fase 0: Crear estructura del proyecto (1 min)

Pregunta el nombre del proyecto y crea la carpeta con toda la estructura:

```python
import os
from pathlib import Path

project_name = input("¿Nombre del proyecto? (ej: mensadef): ").strip().lower()
folder_name = f"rag-{project_name}"
project_root = Path("..") / folder_name  # hermano de .github/

folders = [
    "knowledge/pdfs",
    "knowledge/procedimientos",
    "knowledge/codigo",
    "knowledge/presentaciones",
    "docs",
    "outputs",
    "logs"
]

project_root.mkdir(parents=True, exist_ok=True)
for folder in folders:
    (project_root / folder).mkdir(parents=True, exist_ok=True)

print(f"✅ Creada carpeta: {folder_name}/")
print(f"   Añade tus documentos en {folder_name}/knowledge/ antes de continuar")
```

### Fase 1: Entrevista al usuario (2 min)

```python


import os

knowledge_path = "knowledge"
required_dirs = ["pdfs", "procedimientos", "codigo", "presentaciones"]

if not os.path.exists(knowledge_path):
    os.makedirs(knowledge_path)
    for subdir in required_dirs:
        os.makedirs(f"{knowledge_path}/{subdir}")
    print("âœ… Created knowledge/ folder structure")
else:
    missing = [d for d in required_dirs if not os.path.exists(f"{knowledge_path}/{d}")]
    if missing:
        for d in missing:
            os.makedirs(f"{knowledge_path}/{d}")
        print(f"âœ… Created missing subdirs: {missing}")



pdf_count = len(os.listdir(f"{knowledge_path}/pdfs"))
proc_count = len(os.listdir(f"{knowledge_path}/procedimientos"))
code_count = len(os.listdir(f"{knowledge_path}/codigo"))
ppt_count = len(os.listdir(f"{knowledge_path}/presentaciones"))

print(f"\nðŸ“‚ Current documentation:")
print(f"   PDFs: {pdf_count} files")
print(f"   Procedimientos: {proc_count} files")
print(f"   CÃ³digo: {code_count} files")
print(f"   Presentaciones: {ppt_count} files")
```

### Phase 2: User Interview (5 min)

```
Ask EXACTLY these 5 questions (no more, no less):

1ï¸âƒ£  Project name?
    Example: "rag-builder"
    
2ï¸âƒ£  Project description? (1-2 sentences)
    Example: "Customer management system for retail banking"
    
3ï¸âƒ£  Total documentation size?
    Options: 
      - small (< 1GB)
      - medium (1-10GB)
      - large (> 10GB)
    
4ï¸âƒ£  Monthly Azure budget?
    Default: $2,000
    
5ï¸âƒ£  Preferred Azure region?
    Default: eastus
    Options: eastus, westus2, northeurope, southeastasia

Store answers in: outputs/interview-{timestamp}.json
```

### Phase 3: Recommend Config (1 min - AUTO)

```python



recommendations = {
    "small": {
        "openai": {"tier": "S0", "model": "gpt-4o", "tokens": "2M/mo", "cost": 1200},
        "search": {"tier": "Standard", "replicas": 1, "cost": 200},
        "appinsights": {"retention": "30 days", "cost": 50},
        "total": 1450
    },
    "medium": {
        "openai": {"tier": "S0", "model": "gpt-4o", "tokens": "2M/mo", "cost": 1200},
        "search": {"tier": "Standard", "replicas": 2, "cost": 250},
        "appinsights": {"retention": "30 days", "cost": 50},
        "total": 1500
    },
    "large": {
        "openai": {"tier": "S1", "model": "gpt-4o", "tokens": "4M/mo", "cost": 2400},
        "search": {"tier": "Standard", "replicas": 3, "cost": 300},
        "appinsights": {"retention": "30 days", "cost": 50},
        "total": 2750
    }
}



config = recommendations[doc_size]

print(f"""
ðŸ“Š RECOMMENDED CONFIGURATION:
   Azure OpenAI:  {config['openai']['tier']} - {config['openai']['tokens']} - ${config['openai']['cost']}/mo
   Search:        {config['search']['tier']} ({config['search']['replicas']} replicas) - ${config['search']['cost']}/mo
   AppInsights:   {config['appinsights']['retention']} - ${config['appinsights']['cost']}/mo
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   TOTAL:         ${config['total']}/mo

Budget provided: ${budget}/mo
Status: {"âœ… FITS BUDGET" if config['total'] <= budget else "âš ï¸  EXCEEDS BUDGET"}
""")



print("Proceed with this configuration? (Y/n)")
```

### Phase 4: Validate Costs (1 min - AUTO)

```python





if config_cost > user_budget:
    print(f"""
âš ï¸  Configuration (${config_cost}) exceeds budget (${user_budget}).

Options:
  A) Continue anyway (costs will accumulate)
  B) Use smaller tier
  C) Increase budget
  D) Cancel

Your choice? (A/B/C/D)
    """)



import subprocess
result = subprocess.run([
    "az", "vm", "list-skus",
    "--location", region,
    "--query", "[?family=='StandardSv5'].capabilities[?name=='vCPUs'].value",
    "--output", "json"
], capture_output=True)

if not result.stdout:
    print(f"""
âš ï¸  Region {region} may have quota issues.

Trying alternative regions...
    """)
    # Try: westus2, northeurope, etc.



try:
    from azure.identity import DefaultAzureCredential
    # Try to get model capability in region
except:
    print("âš ï¸  Could not verify OpenAI in this region. Continuing...")

print("âœ… Cost validation passed")
```

### Phase 5: Deploy Infrastructure (10 min - AUTO, SILENT)

```bash
#!/bin/bash




echo "ðŸš€ Deploying Azure infrastructure..."

az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${REGION}"

az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file infra/main.bicep \
  --parameters \
    openaiTier="${OPENAI_TIER}" \
    searchTier="${SEARCH_TIER}" \
    appInsightsRetention="${APPINSIGHTS_RETENTION}"

echo "âœ… Infrastructure deployed"
```

**Show Progress:**
```
â³ Deploying Azure infrastructure...
   â³ Creating Resource Group...
   âœ… Resource Group created
   â³ Deploying Azure OpenAI...
   âœ… Azure OpenAI deployed
   â³ Deploying AI Search...
   âœ… AI Search deployed
   â³ Deploying Application Insights...
   âœ… Application Insights deployed

âœ… All infrastructure ready!
```

### Phase 6: Index Documents (10-15 min - AUTO, SHOW PROGRESS)

```python
import os
from pathlib import Path
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.identity import DefaultAzureCredential

knowledge_path = "knowledge"

for doc_type, subdir in [
    ("PDFs", "pdfs"),
    ("Procedimientos", "procedimientos"),
    ("CÃ³digo", "codigo"),
    ("Presentaciones", "presentaciones")
]:
    folder = f"{knowledge_path}/{subdir}"
    files = os.listdir(folder)
    
    print(f"\nâ³ Indexing {doc_type}...")
    
    for file in files:
        filepath = os.path.join(folder, file)
        
        # Process file (OCR for PDFs, parse for others)
        if file.endswith('.pdf'):
            chunks = extract_pdf(filepath)
        elif file.endswith(('.docx', '.xlsx')):
            chunks = extract_office(filepath)
        elif file.endswith(('.py', '.sql', '.js')):
            chunks = extract_code(filepath)
        elif file.endswith('.pptx'):
            chunks = extract_ppt(filepath)
        else:
            continue
        
        # Generate embeddings
        embeddings = [generate_embedding(c) for c in chunks]
        
        # Upload to Azure Search
        search_client.upload_documents([...])
    
    print(f"   âœ… Indexed {len(files)} {doc_type} files")

print("\nâœ… Indexing complete!")
```

**Show Summary:**
```
ðŸ“š Indexing complete!

âœ… PDFs:          42 files â†’ 1,200 chunks
âœ… Procedimientos: 15 files â†’ 350 chunks
âœ… CÃ³digo:        8 files â†’ 400 chunks
âœ… Presentaciones: 3 files â†’ 180 chunks
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   TOTAL:       2,130 chunks indexed
```

### Phase 7: Setup Credentials (1 min - AUTO)

```python
import os
import json



openai_key = os.getenv("AZURE_OPENAI_API_KEY")
openai_endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
search_key = os.getenv("AZURE_SEARCH_API_KEY")
search_endpoint = os.getenv("AZURE_SEARCH_ENDPOINT")
appinsights_key = os.getenv("AZURE_APPINSIGHTS_KEY")



env_content = f"""# RAG Configuration (Generated: {timestamp})



AZURE_OPENAI_ENDPOINT={openai_endpoint}
AZURE_OPENAI_API_KEY={openai_key}
OPENAI_CHAT_MODEL=gpt-4o
OPENAI_DEPLOYMENT=gpt-4o



AZURE_SEARCH_ENDPOINT={search_endpoint}
AZURE_SEARCH_API_KEY={search_key}
SEARCH_INDEX=rag-documents



AZURE_APPINSIGHTS_KEY={appinsights_key}



RAG_TOP_K=5
RAG_TEMPERATURE=0.7
RAG_MAX_TOKENS=1000
"""

with open(".env", "w") as f:
    f.write(env_content)

print("âœ… Credentials saved to .env")
```

### Phase 8: Test Connections (2 min - AUTO)

```python
import os
from dotenv import load_dotenv
from azure.openai import AzureOpenAI
from azure.search.documents import SearchClient

load_dotenv()



try:
    client = AzureOpenAI(
        api_key=os.getenv("AZURE_OPENAI_API_KEY"),
        api_version="2024-05-01-preview",
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
    )
    models = client.models.list()
    print("âœ… OpenAI connected")
except Exception as e:
    print(f"âŒ OpenAI failed: {e}")



try:
    search_client = SearchClient(
        endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"),
        index_name="rag-documents",
        credential=AzureKeyCredential(os.getenv("AZURE_SEARCH_API_KEY"))
    )
    search_client.get_document_count()
    print("âœ… Search connected")
except Exception as e:
    print(f"âŒ Search failed: {e}")



try:
    from azure.monitor.opentelemetry import configure_azure_monitor
    configure_azure_monitor()
    print("âœ… AppInsights connected")
except Exception as e:
    print(f"âŒ AppInsights failed: {e}")
```

### Phase 9: Ready! Show Usage (1 min - AUTO)

```
ðŸŽ‰ YOUR RAG IS READY!

Choose your query mode:

â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

ðŸ”¹ MODE A: Quick Queries (CLI)
   
   Usage:
   $ python scripts/consulta/consultar.py "Â¿CuÃ¡l es la polÃ­tica X?"
   
   Best for: Quick questions, one-off queries
   Latency: 2 seconds
   Cost: $0.02 per query
   
   Example output:
   > Question: Â¿CuÃ¡l es la polÃ­tica de retenciÃ³n?
   > Answer: SegÃºn el documento 'data-retention.docx'...
   > Sources: data-retention.docx (p.3), api-specs.xlsx (Sheet 2)
   > Time: 2.1s | Tokens: 340 | Cost: $0.02

â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

ðŸ”¹ MODE B: Chat Conversational
   
   Usage:
   $ copilot-cli run .github/agents/rag-chat.agent.md
   
   Best for: Multi-turn conversations, follow-ups, deep dives
   Latency: 5 seconds per turn
   Cost: $0.05 per turn
   Context: Remembers last 10 interactions
   
   Example flow:
   > Q1: Â¿CÃ³mo despliego el sistema?
   < A1: SegÃºn deployment-guide.pdf...
   > Q2: Â¿Y si falla la conexiÃ³n?
   < A2: Refers back to Q1 context + new answer

â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

ðŸ”¹ MODE C: REST API (For App Integration)
   
   Usage:
   $ python scripts/consulta/servidor-api.py --port 8000
   
   Then from your app:
   curl -X POST http://localhost:8000/query \\
     -H "Content-Type: application/json" \\
     -d '{"query": "Â¿CuÃ¡l es X?", "top_k": 5}'
   
   Best for: Web apps, dashboards, workflows
   Latency: 3 seconds per query
   Cost: $0.03 per query
   Features: Batch queries, health checks, CORS enabled

â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

ðŸ“– Read detailed comparison: QUERY_MODES.md

Next steps:
  1. Choose your mode (A, B, or C)
  2. Try your first query
  3. Customize as needed

Setup saved to: outputs/setup-summary-{timestamp}.json
```

---

## Error Handling

### If Folder Missing
```
âš ï¸ knowledge/ folder not found.
   Creating structure...
   âœ… Created knowledge/{pdfs, procedimientos, codigo, presentaciones}
   
Please add your documentation files and run wizard again.
```

### If Interview Fails
```
âŒ User input error: Budget must be > 0
   Try again...
```

### If Deployment Fails
```
âŒ Azure deployment failed: Quota exceeded for region eastus

Suggestions:
  A) Try region: westus2
  B) Request quota increase (takes 24h)
  C) Reduce tier size

Your choice? (A/B/C)
```

### If Indexing Fails Partially
```
âš ï¸ Indexing partial success:
   âœ… 2,100 chunks indexed successfully
   âŒ 30 chunks failed (see errors below)

Failed files:
  - corrupted-file.pdf: OCR failed
  - binary-code.so: Not a text file

Continuing with successful chunks. Review logs: logs/rag.log
```

### If Connection Test Fails
```
âŒ Connection test failed:
   âœ… OpenAI: OK
   âŒ Search: Could not connect (check API key)
   âš ï¸  AppInsights: Timeout

Troubleshooting:
  1. Check .env file exists
  2. Verify API keys: cat .env
  3. Check Azure region availability
  4. Run: az login --tenant {tenant-id}

Retry? (Y/n)
```

---

## Resumption Support

If wizard is interrupted, save checkpoint:

```json
{
    "project_name": "rag-builder",
  "phase": 5,
  "phase_name": "Index Documents",
  "status": "in-progress",
  "timestamp": "2026-05-13T10:30:00Z",
  "indexed_chunks": 1250,
  "next": "Complete indexing + Phase 6"
}
```

On restart:
```
ðŸ”„ Detected incomplete setup from 2026-05-13 10:30

Last phase: Phase 5 (Index Documents)
Progress: 1,250 / 2,130 chunks indexed

Resume from Phase 5? (Y/n)
```

---

## Success Criteria

âœ… User sees ONE of these 3 commands and can run it immediately:
```bash
python scripts/consulta/consultar.py "Â¿CuÃ¡l es X?"
copilot-cli run .github/agents/rag-chat.agent.md
python scripts/consulta/servidor-api.py --port 8000
```

âœ… First query returns a result within 2-5 seconds

âœ… Setup summary saved to `outputs/setup-summary-{timestamp}.json`

âœ… User NEVER had to click Azure Portal

