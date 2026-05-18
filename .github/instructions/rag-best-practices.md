---
description: 'RAG Best Practices from Microsoft Learn: agentic retrieval vs classic RAG, content preparation, relevance tuning'
---

# RAG Best Practices for MENSADEF

**Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)

> "RAG is a pattern that extends LLM capabilities by grounding responses in your proprietary content. While conceptually simple, RAG implementations face significant challenges."

---

## The Challenge of RAG

### 1. Query Understanding

**The Problem:**  
Users ask conversational, complex, or vague questions:
> "¿Cuáles son las políticas de PTO para empleados remotos contratados después de 2023?"

But documents say:
- "time off" (English docs)
- "telecommute"
- "recent hires"

**Traditional keyword search fails.** It looks for exact matches, not intent.

---

### 2. Multi-Source Data Access

**The Problem:**  
Enterprise content spans multiple platforms:
- SharePoint (HR policies)
- Databases (employee records)
- Blob Storage (PDFs, Word docs)
- Code repositories (SQL, procedures)

**Creating a unified search corpus without disrupting data operations is essential.**

---

### 3. Token Constraints

**The Problem:**  
LLMs accept limited tokens (~128K for gpt-4o):
- You have 10,000 pages of documentation
- Sending everything wastes tokens and degrades quality
- Response time becomes unacceptable

**Your retrieval system must return highly relevant, concise results — not exhaustive document dumps.**

---

### 4. Response Time Expectations

**The Problem:**  
Users expect AI-powered answers in **3-5 seconds**, not minutes.

**The retrieval system must balance thoroughness with speed.**

---

### 5. Security and Governance

**The Problem:**  
Opening private content to LLMs requires granular access control:
- Finance data should only be accessible to finance team
- Even when an executive asks the chatbot
- Users must only retrieve authorized content

---

## How Azure AI Search Solves These Challenges

### Azure AI Search: Two Approaches

#### 1. **Agentic Retrieval** (Recommended for New Projects)

**Use when:**
- Your client is an agent or chatbot
- You need the highest possible relevance and accuracy
- Your queries are complex or conversational
- You want structured responses with citations and query details
- You're building new RAG implementations

**How it works:**

```
User Query
    ↓
LLM analyzes query → generates multiple sub-queries
    ↓
Parallel execution across all sub-queries
    ↓
Parallel execution (not sequential)
    ↓
Structured response with grounding data
    ↓
Built-in citation tracking
    ↓
Query activity log explains what was searched
    ↓
Optional answer synthesis (uses LLM-formulated answer)
```

**Features:**
- Context-aware query planning using conversation history
- Parallel execution of multiple focused sub-queries
- Structured responses with grounding data, citations, execution metadata
- Built-in semantic ranking for optimal relevance
- Optional answer synthesis that uses LLM-formulated answer in response

**Architecture:**
```
Knowledge Sources (multi-source)
    ↓
Knowledge Base (unified interface)
    ↓
Retrieve Action (called from agent code as tool)
    ↓
LLM Agentic Reasoning
    ↓
Agent responds to user
```

**Example Workflow:**

```python
from azure_ai_search import AgenticRetrieval

retriever = AgenticRetrieval(
    service_endpoint="https://rag-builder.search.windows.net/",
    admin_key="...",
    knowledge_base="rag-kb-mensadef"
)

# Agent queries knowledge base
response = retriever.retrieve(
    query="¿Cuáles son las políticas de PTO para remotos?",
    reasoning_effort="medium",  # minimal/low/medium
    top_k=5
)

# Structured response
print(response.answer)           # LLM-generated answer
print(response.citations)       # [{"text": "...", "source": "..."}]
print(response.follow_ups)      # Suggested next questions
```

---

#### 2. **Classic RAG** (For GA/Stable Features)

**Use when:**
- You need generally available (GA) features only
- Simplicity and speed are priorities over advanced relevance
- You have existing orchestration code you want to preserve
- You need fine-grained control over the query pipeline

**How it works:**

```
User Query
    ↓
Application sends single query to Azure AI Search
    ↓
Hybrid Query (keyword + vector search)
    ↓
Results ranked by semantic relevance
    ↓
Application orchestrates handoff to LLM
    ↓
LLM formulates answer using flattened result set
    ↓
Response returned to user
```

**Features:**
- Hybrid queries combine keyword (BM25) and vector search for maximum recall
- Semantic ranking re-scores results based on meaning, not just keywords
- Vector similarity search matches concepts, not exact terms
- Simpler architecture with fewer failure points
- Fine-grained control over the query pipeline

**Example Workflow:**

```python
from azure.search.documents import SearchClient
from azure.search.documents.models import VectorizedQuery

client = SearchClient(
    endpoint="https://rag-builder.search.windows.net/",
    index_name="rag-builder-index",
    credential=AzureKeyCredential(key)
)

# Hybrid query: keyword + vector
query_vector = generate_embedding("PTO policy remote")
results = client.search(
    search_text="política PTO empleados remotos",
    vector_queries=[VectorizedQuery(vector=query_vector, k_nearest_neighbors=5)],
    select=["title", "content", "metadata"],
    top=5,
    semantic_configuration_name="default"
)

# Application passes results to LLM
context = "\n".join([r["content"] for r in results])
response = llm.generate(
    query="¿Cuáles son las políticas de PTO para remotos?",
    context=context
)
```

---

## Content Preparation for RAG

### How to Maximize Relevance and Recall

#### 1. **Chunking Strategy**

**Problem:**  
Large documents (50+ pages) don't work well in vector search. Query results return entire documents instead of relevant sections.

**Solution:**  
Split documents into semantic chunks (200-500 tokens each):

```
Document: "HR_Handbook_2024.pdf" (100 pages)
    ↓
Chunk 1: "Section 1.1: Employment Policies" (250 tokens)
Chunk 2: "Section 1.2: Work Hours" (300 tokens)
Chunk 3: "Section 2.1: PTO Policy - General" (400 tokens)
Chunk 4: "Section 2.2: PTO Policy - Remote Workers" (350 tokens)
...
Chunk N: "Section 8.5: Termination Procedures" (275 tokens)
```

**Best Practices:**
- Preserve semantic boundaries (don't split mid-sentence/section)
- Include parent document metadata (title, source, author)
- Overlap chunks slightly (20-50 tokens) for context
- Use syntax-aware splitting for code files

**Azure AI Search: Built-in Chunking**
```bicep
// In knowledge sources (agentic retrieval), 
// chunking is auto-generated with intelligent defaults
```

---

#### 2. **Vectorization**

**Problem:**  
Keyword search fails on conceptual queries. "PTO policy" and "time off" are semantically identical but textually different.

**Solution:**  
Create embeddings (vector representations) for every chunk.

```
Chunk Text: "Time off policy allows 30 days annually"
    ↓
Embedding Model: Azure OpenAI (text-embedding-3-small)
    ↓
Vector: [0.234, -0.891, 0.123, ..., 0.567]  (dimension: 1536)
    ↓
Stored in search index alongside text
```

**Query Time:**
```
User Query: "PTO policy"
    ↓
Generate embedding: [0.245, -0.885, 0.131, ..., 0.571]
    ↓
Find similar vectors (cosine similarity)
    ↓
Retrieve relevant chunks
```

**Best Practices:**
- Use Azure OpenAI embeddings (or Azure Vision for images)
- Keep embedding model consistent (don't switch mid-project)
- Dimension trade-offs: Higher dims = better accuracy, higher cost
- Multilingual embeddings support 50+ languages

---

#### 3. **Metadata Extraction**

**Problem:**  
Search results lack context. User doesn't know where information came from.

**Solution:**  
Extract and store metadata with each chunk:

```json
{
  "id": "chunk-123",
  "content": "Time off policy allows 30 days annually...",
  "metadata": {
    "source_document": "HR_Handbook_2024.pdf",
    "source_section": "2.1: PTO Policy - General",
    "page_number": 12,
    "author": "HR Department",
    "last_updated": "2024-01-15",
    "document_type": "policy",
    "applicable_to": ["remote", "onsite"]
  }
}
```

**Citation Generation:**
```python
# When generating response, include metadata
response = {
  "answer": "The PTO policy allows 30 days annually...",
  "citations": [
    {
      "text": "30 days annually",
      "source": "HR_Handbook_2024.pdf",
      "section": "2.1",
      "page": 12
    }
  ]
}
```

---

#### 4. **Language & Multilingual Support**

**Problem:**  
MENSADEF likely has Spanish documents. Standard keyword search doesn't understand Spanish stemming/lemmatization.

**Solution:**  
Use appropriate language analyzers:

```bicep
resource searchIndex 'Microsoft.Search/searchServices/indexes@2023-11-01' = {
  name: '${searchService.name}/rag-builder-index'
  properties: {
    fields: [
      {
        name: 'content'
        type: 'Edm.String'
        searchable: true
        analyzer: 'es.microsoft'  // Spanish analyzer
      }
    ]
  }
}
```

**Analyzer Options:**
- `es.microsoft` - Spanish (Microsoft analyzer)
- `en.microsoft` - English (Microsoft analyzer)
- `es.lucene` - Spanish (Lucene analyzer)
- More than 50 language analyzers available

---

#### 5. **OCR for PDFs & Images**

**Problem:**  
PDFs and images contain text that can't be indexed without OCR.

**Solution:**  
Azure AI Search has built-in OCR (via skills pipeline):

```bicep
resource ocrSkill 'Microsoft.Search/searchServices/skillsets@2023-11-01' = {
  name: '${searchService.name}/ocr-skillset'
  properties: {
    skills: [
      {
        '@odata.type': '#Microsoft.Skills.Vision.OcrSkill'
        context: '/document/normalized_images/*'
        textExtractionAlgorithm: 'printed'  // or 'handwritten'
        lineEnding: 'space'
      }
    ]
  }
}
```

---

### Content Preparation Checklist

- [ ] **Large documents:** Split into chunks (200-500 tokens each)
- [ ] **Vectorization:** All chunks have embeddings
- [ ] **Metadata:** Source, date, author, document type extracted
- [ ] **Language:** Appropriate analyzer configured
- [ ] **PDFs/Images:** OCR applied
- [ ] **Synonyms:** Synonym maps for terminology mismatches (PTO = "time off", "vacation days")
- [ ] **Filters:** Document-level security metadata included
- [ ] **Scoring:** Key fields boosted (title > body)
- [ ] **Testing:** Search quality validated on sample queries

---

## Relevance Tuning

### 1. Hybrid Queries (Keyword + Vector)

**Classic approach:** Keyword search ONLY (BM25)
```
Query: "PTO policy"
Results: Exact phrase matches only
Problem: Misses "vacation days", "time off", "leave policy"
```

**Better approach:** Hybrid search (keyword + vector)
```
Query: "PTO policy"
    ├─► Keyword search: "PTO policy", "time off", "vacation"
    └─► Vector search: Semantically similar content
Result: Combines best of both (high recall + high precision)
```

**Implementation:**
```python
from azure.search.documents.models import HybridSearch, VectorizedQuery

results = client.search(
    search_text="PTO policy",  # Keyword component
    vector_queries=[VectorizedQuery(...)],  # Vector component
    select=["title", "content"],
    top=5,
    semantic_configuration_name="default"
)
```

---

### 2. Semantic Ranking

**Problem:**  
Top results from hybrid search might not be semantically relevant.

```
Top 3 Results:
1. "Company PTO policy (50 pages)" - High keyword match, low relevance
2. "Remote work benefits guide" - Lower match, high relevance
3. "Payroll processing manual" - Medium match, no relevance
```

**Solution:**  
Re-rank results using semantic ranking (cross-encoder model):

```
Original Ranking (BM25 score):
1. "Company PTO policy" - Score: 8.5
2. "Remote work benefits" - Score: 7.2
3. "Payroll manual" - Score: 6.1

After Semantic Re-ranking:
1. "Remote work benefits" - Semantic score: 2.8 (most relevant)
2. "Company PTO policy" - Semantic score: 2.1
3. "Payroll manual" - Semantic score: 0.4
```

**Implementation:**
```bicep
// Enable in search index
semanticConfiguration: {
  name: 'default'
  prioritizedFields: {
    contentFields: [{ fieldName: 'content' }]
    keywordsFields: [{ fieldName: 'keywords' }]
  }
}
```

---

### 3. Scoring Profiles

**Problem:**  
Some fields are more important than others.

```
User query: "PTO policy"
Results:
- Match in title (policy document) - Should rank higher
- Match in body (mentions PTO once) - Should rank lower
- Match in footnote (stray reference) - Should rank lowest
```

**Solution:**  
Apply scoring profiles to boost key fields:

```bicep
scoringProfiles: [
  {
    name: 'relevanceProfile'
    textWeights: {
      weights: {
        'title': 3          // Title matches rank 3x higher
        'content': 1        // Body matches - neutral
        'metadata': 0.5     // Metadata matches - lower weight
      }
    }
    functions: [
      {
        fieldName: 'last_updated'
        type: 'freshness'
        freshness: { boostingDurationInDays: 90 }  // Boost recent docs
      }
    ]
  }
]
```

---

### 4. Vector Search Parameters

**Vector Weighting in Hybrid Queries:**
```python
# Default: 50% keyword + 50% vector
results = client.search(
    search_text="query",
    vector_queries=[
      VectorizedQuery(
        vector=embedding,
        k_nearest_neighbors=5,
        weight: 0.8  # 80% weight on vector search
      )
    ],
    # Top 5 keyword results + top 5 vector results
    # Re-ranked by hybrid score
)
```

**Minimum Thresholds:**
```python
# Exclude low-scoring results
results = client.search(
    search_text="query",
    vector_queries=[VectorizedQuery(...)],
    filter="search.score(any()) > 0.5"  # Only results with score > 0.5
)
```

---

## Query Understanding & Sub-Query Planning

### Agentic Retrieval: Multi-Query Strategy

**Problem:**  
User asks complex question that can't be answered with single query.

**User Query:**
> "¿Cuáles son las políticas de vacaciones para empleados remotos contratados después de 2023 que trabajan en el sector de Defensa?"

**Traditional RAG:**
Single query → Single result set → Single answer
(Likely misses important context)

**Agentic Retrieval:**
LLM breaks down question → Multiple focused sub-queries → Parallel search

```
Original Query:
"¿Cuáles son las políticas de vacaciones para empleados remotos 
 contratados después de 2023 que trabajan en el sector de Defensa?"
    ↓
LLM Sub-query Generation (using conversation history for context)
    ├─► Sub-query 1: "Políticas de vacaciones empleados remotos"
    ├─► Sub-query 2: "Requisitos para empleados nuevos 2023"
    └─► Sub-query 3: "Especificaciones sector Defensa"
    ↓
Parallel Search Execution (much faster than sequential!)
    ├─► Search 1: Results [chunk-1, chunk-2, chunk-3, ...]
    ├─► Search 2: Results [chunk-4, chunk-5, chunk-6, ...]
    └─► Search 3: Results [chunk-7, chunk-8, chunk-9, ...]
    ↓
Semantic Re-ranking (all results)
    └─► Top 5 most relevant across all searches
    ↓
Answer Synthesis
    └─► LLM formulates comprehensive answer with citations
```

---

## Security: Document-Level Access Control

### Scenario

```
Executive asks: "What's our current spending on IT contractors?"
    ↓
Without DLS: RAG returns Finance confidential data (RISK!)
    ↓
With DLS: Only Finance team sees Financial documents
           Executive gets "No authorization for this data"
```

### Implementation

**Index-time:**
```json
{
  "id": "finance-budget-2024",
  "title": "Q1 2024 Budget Report",
  "content": "...",
  "allowed_departments": ["Finance", "CFO-Office"],
  "allowed_users": ["cfo@company.com", "finance-manager@company.com"]
}
```

**Query-time:**
```python
# User requesting document
user = current_user()  # John (Finance team)
user_departments = ["Finance"]

# Apply security filter
filter_expression = f"""
  allowed_departments/any(d: search.in(d, '{','.join(user_departments)}'))
  OR allowed_users/any(u: search.in(u, '{user.email}'))
"""

results = client.search(
    search_text="budget",
    filter=filter_expression
)
```

---

## Performance Tuning Checklist

- [ ] **Hybrid queries enabled** (keyword + vector)
- [ ] **Semantic ranking enabled** (cross-encoder re-scoring)
- [ ] **Scoring profiles applied** (boost key fields)
- [ ] **Vector search tuned** (weighting, minimum thresholds)
- [ ] **Top-k results limited** (top: 5-10, not 100)
- [ ] **Filters optimized** (narrow result set before ranking)
- [ ] **Replicas scaled** (1+ for multi-user scenarios)
- [ ] **Query timeouts configured** (default: 30s)
- [ ] **Caching for frequent queries** (if applicable)

---

## Cost Optimization

### Tier Selection

| Use Case | OpenAI Tier | Search Tier | Cost/Month |
|----------|-------------|------------|-----------|
| Development/Testing | S0 | Standard 1 replica | $1,450 |
| Production (HA) | S1 | Standard 2-3 replicas | $2,800 |
| High-volume | S1 | Premium | $4,500+ |

### Strategies

1. **Use cheaper models** (gpt-4o vs gpt-4o)
2. **Optimize embedding dimension** (1024 vs 1536)
3. **Reduce Search replicas** (for non-critical environments)
4. **Set App Insights retention** (30 days vs 90 days)
5. **Enable result sampling** (if accurate metrics not critical)

---

## Monitoring & Observability

### Key Metrics

```
Application Insights Dashboard

Query Performance:
├─ Latency (e2e) - Target: < 5 seconds
├─ Search latency - Target: < 1 second
├─ OpenAI inference latency - Target: < 2 seconds
└─ P95 latency - Target: < 10 seconds

Relevance:
├─ Average relevance score
├─ Citation count per answer
└─ Follow-up suggestion click rate

Cost:
├─ Cost per query
├─ Daily/monthly cost trend
└─ Cost breakdown by model

Errors:
├─ Error rate (%)
├─ Top error types
└─ Recovery success rate
```

---

## Summary: Agentic Retrieval vs Classic RAG

| Aspect | Agentic Retrieval | Classic RAG |
|--------|-----------------|------------|
| **Best For** | Agents, chatbots, complex queries | Simple, GA-only scenarios |
| **Query Planning** | LLM-assisted (sub-queries) | Single query |
| **Execution** | Parallel sub-queries | Single request |
| **Response** | Structured (citations, metadata) | Flat result set |
| **Relevance** | Highest (multi-faceted) | Good (single query) |
| **Speed** | Moderate (multiple searches) | Fast (one request) |
| **Maturity** | Preview (new features) | GA (stable) |
| **Cost** | Slightly higher (more queries) | Lower (single query) |

**Recommendation for MENSADEF:**
- **New implementations:** Use Agentic Retrieval
- **Existing systems:** Consider migrating to agentic retrieval for accuracy gains
- **Hybrid:** Some teams use both (classic for simple Q&A, agentic for complex analysis)

---

## References

- 📚 [RAG Overview (Microsoft Learn)](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)
- 🔍 [Hybrid Search](https://learn.microsoft.com/en-us/azure/search/hybrid-search-overview)
- ⭐ [Semantic Ranking](https://learn.microsoft.com/en-us/azure/search/semantic-ranking)
- 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md)
- 📋 [AGENTS.md](AGENTS.md)
