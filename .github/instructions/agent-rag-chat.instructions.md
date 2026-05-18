**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)




**Purpose:** Multi-turn conversational RAG with context memory. Interactive mode.

**User Entry:** `copilot-cli run .github/agents/rag-chat.agent.md`

**Expected Duration:** Ongoing (user decides when to exit)

---

## âœ… Chat Mode Checklist

- [ ] Load conversation history (if any)
- [ ] Show welcome message
- [ ] Enter chat loop (read user input)
- [ ] For each message:
  - [ ] Search documents
  - [ ] Generate response with context
  - [ ] Show response + sources
  - [ ] Save to history
- [ ] Allow context switching ("reset", "export", "quit")
- [ ] Save final session to outputs/

---

## Session Initialization (1 min)

```python
import os
import json
from datetime import datetime
from pathlib import Path



session_id = datetime.now().strftime("%Y%m%d-%H%M%S")
session_file = f"outputs/chat-history-{session_id}.json"



conversation = {
    "session_id": session_id,
    "start_time": datetime.now().isoformat(),
    "turns": [],
    "stats": {
        "total_questions": 0,
        "total_tokens": 0,
        "total_cost": 0.0,
        "average_latency_ms": 0
    }
}

print(f"""
ðŸ¤– RAG Chat Started (Session: {session_id})

Commands:
  â€¢ /history    - Show conversation history
  â€¢ /reset      - Clear conversation context
  â€¢ /export     - Save session
  â€¢ /help       - Show help
  â€¢ /quit       - Exit

Type your question or command:
""")
```

---

## Chat Loop (Ongoing)

```python
import time

while True:
    # Read user input
    user_input = input("\n> ").strip()
    
    if not user_input:
        continue
    
    # Handle commands
    if user_input.lower() == "/quit":
        break
    elif user_input.lower() == "/history":
        show_history(conversation)
        continue
    elif user_input.lower() == "/reset":
        conversation["turns"] = []
        print("âœ… Conversation context reset")
        continue
    elif user_input.lower() == "/export":
        save_session(conversation, session_file)
        continue
    elif user_input.lower() == "/help":
        show_help()
        continue
    
    # Process query
    print("\nâ³ Searching documents...")
    start_time = time.time()
    
    # 1. Search documents with context from previous turns
    query = reformulate_with_context(user_input, conversation["turns"])
    search_results = search_rag(query, top_k=5)
    search_latency = (time.time() - start_time) * 1000
    
    print(f"   Found {len(search_results)} relevant documents ({search_latency:.0f}ms)")
    
    # 2. Generate response with context
    print("â³ Generating response...")
    start_time = time.time()
    
    response, tokens_used, citations = generate_response_with_context(
        user_query=user_input,
        search_results=search_results,
        conversation_history=conversation["turns"][-5:]  # Last 5 turns for context
    )
    
    inference_latency = (time.time() - start_time) * 1000
    
    # 3. Display response
    print(f"""
ðŸ“ Answer:
{response}

ðŸ“š Sources:
""")
    for i, citation in enumerate(citations, 1):
        print(f"   {i}. {citation['file']} (p. {citation.get('page', '?')})")
    
    print(f"\nâ±ï¸  Latency: {search_latency:.0f}ms (search) + {inference_latency:.0f}ms (inference) = {search_latency + inference_latency:.0f}ms total")
    print(f"ðŸ’° Cost: ${tokens_used * 0.0001:.4f}")
    
    # 4. Save turn to history
    turn = {
        "turn_number": len(conversation["turns"]) + 1,
        "user_query": user_input,
        "reformulated_query": query,
        "ai_response": response,
        "citations": citations,
        "tokens_used": tokens_used,
        "search_latency_ms": search_latency,
        "inference_latency_ms": inference_latency,
        "timestamp": datetime.now().isoformat()
    }
    
    conversation["turns"].append(turn)
    
    # 5. Update stats
    conversation["stats"]["total_questions"] += 1
    conversation["stats"]["total_tokens"] += tokens_used
    conversation["stats"]["total_cost"] += tokens_used * 0.0001
    
    # Auto-save every 5 turns
    if conversation["stats"]["total_questions"] % 5 == 0:
        save_session(conversation, session_file)
        print(f"ðŸ’¾ Session auto-saved (turn {conversation['stats']['total_questions']})")
```

---

## Function: Reformulate with Context

**Smart query rewriting using previous turns:**

```python
def reformulate_with_context(user_query, history):
    """
    Reformulate user query to include implicit context from previous turns.
    
    Example:
    Turn 1: Q: "Â¿CÃ³mo despliego el sistema?"
    Turn 2: Q: "Â¿Y si falla?"
    â†’ Reformulated: "Â¿QuÃ© pasa si falla el despliegue del sistema?"
    """
    
    if not history:
        return user_query  # First question, no context
    
    # Get previous question + answer
    last_turn = history[-1]
    previous_context = f"""
Previous question: {last_turn['user_query']}
Previous answer: {last_turn['ai_response'][:200]}...
Current question: {user_query}
"""
    
    # Use LLM to reformulate
    from azure.openai import AzureOpenAI
    client = AzureOpenAI()
    
    reformulation_prompt = f"""Given the conversation context, rewrite the user's question to be standalone and include all necessary context.

{previous_context}

Rewritten standalone question:"""
    
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": reformulation_prompt}],
        max_tokens=100,
        temperature=0.0  # Deterministic
    )
    
    reformulated = response.choices[0].message.content.strip()
    return reformulated
```

---

## Function: Search RAG

```python
from azure.search.documents import SearchClient

def search_rag(query, top_k=5):
    """
    Hybrid search: semantic + keyword
    """
    from azure.search.documents.models import QueryType, QueryCaptionType
    
    search_client = SearchClient(
        endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"),
        index_name="rag-documents",
        credential=AzureKeyCredential(os.getenv("AZURE_SEARCH_API_KEY"))
    )
    
    # Hybrid search (semantic + keyword)
    results = search_client.search(
        search_text=query,
        query_type=QueryType.SEMANTIC,
        query_language="es",  # Spanish
        top=top_k,
        query_caption=QueryCaptionType.EXTRACTIVE,
        search_fields=["content"],
        select=["content", "file", "file_type", "chunk_num", "source_url"]
    )
    
    return list(results)
```

---

## Function: Generate Response with Context

```python
def generate_response_with_context(user_query, search_results, conversation_history):
    """
    Generate response using:
    1. Retrieved documents
    2. Previous conversation turns
    """
    
    from azure.openai import AzureOpenAI
    
    client = AzureOpenAI(
        api_key=os.getenv("AZURE_OPENAI_API_KEY"),
        api_version="2024-05-01-preview",
        azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
    )
    
    # Build context
    document_context = "\n\n".join([
        f"Document: {r.get('file', 'unknown')}\nContent:\n{r.get('content', '')}"
        for r in search_results[:5]
    ])
    
    conversation_context = "\n".join([
        f"Q{i+1}: {turn['user_query']}\nA{i+1}: {turn['ai_response'][:100]}..."
        for i, turn in enumerate(conversation_history[-3:])  # Last 3 turns
    ])
    
    # Prepare prompt
    system_prompt = """You are an expert RAG assistant. 
    
Use the provided documents to answer questions accurately.
If information is not in documents, say "I don't find this info in the documents."
Always cite your sources.
Keep answers concise and professional.
Maintain conversation context for follow-up questions.

Language: Respond in Spanish unless user asks otherwise.
"""
    
    user_prompt = f"""Based on these documents and previous conversation:

DOCUMENTS:
{document_context}

PREVIOUS CONVERSATION:
{conversation_context if conversation_context else "(First question)"}

USER QUESTION:
{user_query}

Provide a clear, concise answer with specific citations."""
    
    # Call LLM
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        temperature=0.7,
        max_tokens=1000,
        top_p=0.95
    )
    
    # Extract response and tokens
    answer = response.choices[0].message.content
    tokens_used = response.usage.total_tokens
    
    # Extract citations from answer
    citations = [
        {
            "file": r.get("file", "unknown"),
            "file_type": r.get("file_type", "unknown"),
            "chunk_num": r.get("chunk_num", 0),
            "page": r.get("page", "?")
        }
        for r in search_results[:3]
    ]
    
    return answer, tokens_used, citations
```

---

## Command: Show History

```python
def show_history(conversation):
    """Display conversation history"""
    if not conversation["turns"]:
        print("No conversation history yet.")
        return
    
    print(f"\nðŸ“œ Conversation History ({len(conversation['turns'])} turns):\n")
    
    for turn in conversation["turns"]:
        print(f"Turn {turn['turn_number']}:")
        print(f"  Q: {turn['user_query']}")
        print(f"  A: {turn['ai_response'][:150]}...")
        print(f"  Sources: {len(turn['citations'])} docs | Latency: {turn['search_latency_ms'] + turn['inference_latency_ms']:.0f}ms")
        print()
```

---

## Command: Reset Context

```python
def reset_context():
    """Reset conversation, start fresh"""
    global conversation
    old_turns = len(conversation["turns"])
    conversation["turns"] = []
    print(f"âœ… Conversation reset (cleared {old_turns} turns)")
```

---

## Command: Export Session

```python
def save_session(conversation, filepath):
    """Save conversation to JSON"""
    
    # Create outputs dir if needed
    Path(filepath).parent.mkdir(parents=True, exist_ok=True)
    
    # Add end time and stats
    conversation["end_time"] = datetime.now().isoformat()
    conversation["stats"]["average_latency_ms"] = (
        sum(t.get("search_latency_ms", 0) + t.get("inference_latency_ms", 0) 
            for t in conversation["turns"]) / len(conversation["turns"])
        if conversation["turns"] else 0
    )
    
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(conversation, f, indent=2, ensure_ascii=False)
    
    print(f"""âœ… Session exported!

File: {filepath}
Turns: {conversation['stats']['total_questions']}
Total cost: ${conversation['stats']['total_cost']:.2f}
Avg latency: {conversation['stats']['average_latency_ms']:.0f}ms
""")
```

---

## Session Exit & Save (On Quit)

```python



print("\nðŸ‘‹ Ending chat session...\n")



save_session(conversation, session_file)



print(f"""
ðŸ“Š Session Summary:
   Duration: {(datetime.fromisoformat(conversation['end_time']) - datetime.fromisoformat(conversation['start_time'])).total_seconds() / 60:.1f} minutes
   Turns: {conversation['stats']['total_questions']}
   Total tokens: {conversation['stats']['total_tokens']}
   Total cost: ${conversation['stats']['total_cost']:.2f}
   Avg latency: {conversation['stats']['average_latency_ms']:.0f}ms
   
Saved to: {session_file}

Thank you for using RAG Chat! ðŸ™
""")

exit(0)
```

---

## Error Handling

### User Query Too Vague
```
âš ï¸ Your question is too vague.

Try being more specific:
  âŒ "Â¿CuÃ¡l es?" â†’ Too vague
  âœ… "Â¿CuÃ¡l es la polÃ­tica de retenciÃ³n de datos?" â†’ Better

Retry: 
```

### No Relevant Documents Found
```
âš ï¸ No documents found for: "xyz"

Suggestions:
  â€¢ Try different keywords
  â€¢ Check what's in your knowledge/ folder
  â€¢ Try a broader question

New question:
```

### LLM Error
```
âŒ OpenAI API error: Rate limit exceeded

Wait a moment and try again...
```

### Search Connection Lost
```
âŒ Lost connection to Azure Search

Troubleshooting:
  â€¢ Check .env file
  â€¢ Verify API keys
  â€¢ Check Azure portal status

Reconnect? (Y/n)
```

---

## Success Criteria

âœ… User can ask questions in natural language

âœ… Responses cite document sources

âœ… Multi-turn context is preserved

âœ… Previous questions inform new ones

âœ… Session automatically saves

âœ… User can export/review history

âœ… Latency is 4-6 seconds per turn

âœ… Cost is ~$0.05 per turn

