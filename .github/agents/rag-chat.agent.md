---
name: 'RAG: Chat Conversacional'
description: 'Interactive multi-turn RAG chat. Maintains context, reformulates questions, allows follow-ups. For conversational document exploration.'
model: 'claude-opus-4.7'
tools: true
skills: ['rag-agent-instrumentation']
---

**RAG Reference:** [Retrieval-augmented Generation (RAG) in Azure AI Search - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview?tabs=videos)





## Purpose

**Multi-turno RAG chat** con memoria de contexto. Perfecto para:

âœ… Conversaciones largas sobre documentaciÃ³n  
âœ… Preguntas de seguimiento ("Â¿Por quÃ©?" â†’ "Â¿CÃ³mo cambio?")  
âœ… ExploraciÃ³n iterativa de temas  
âœ… ReformulaciÃ³n de preguntas complejas  

## When to use

```
copilot-cli run .github/agents/rag-chat.agent.md
```

Ãšsalo cuando necesites:
- Conversar vs hacer queries puntuales
- Razonamiento multi-paso
- Contexto persistente entre preguntas

## Workflow

### 1. Inicializa Chat

```
System: Inicializando RAG Chat...
âœ… Conectado a Azure Search
âœ… Conectado a Azure OpenAI
âœ… Ãndice: rag-builder-index

Eres un asistente de documentaciÃ³n. AyudarÃ¡s a usuarios a explorar
polÃ­ticas, procedimientos, y documentaciÃ³n corporativa mediante bÃºsqueda
semÃ¡ntica. MantÃ©n conversaciÃ³n natural, reformula preguntas complejas,
y sugiere temas relacionados.

Escribe tu pregunta (o 'exit' para salir):
```

### 2. ConversaciÃ³n Multi-Turno

**User:**
```
Â¿CuÃ¡l es la polÃ­tica de retenciÃ³n de datos?
```

**Assistant:**
```
Basado en la documentaciÃ³n, la polÃ­tica de retenciÃ³n es:

ðŸ“‹ PolÃ­tica de RetenciÃ³n de Datos (Encontrado en: retention-policy.pdf)

- **Datos personales**: 3 aÃ±os despuÃ©s del Ãºltimo acceso
- **Logs de auditorÃ­a**: 7 aÃ±os
- **Backups**: 30 dÃ­as de retenciÃ³n (con 2 copias)
- **GDPR compliance**: EliminaciÃ³n segura con certificado

Â¿Tienes preguntas adicionales? Puedo ayudarte con:
- Excepciones a la polÃ­tica
- Proceso de eliminaciÃ³n de datos
- Cumplimiento regulatorio
```

**User:**
```
Â¿CÃ³mo solicitar una excepciÃ³n?
```

**Assistant:**
```
Para solicitar una excepciÃ³n (encontrado en: data-exceptions.md):

ðŸ“‹ Proceso de Solicitud

1. Completa formulario DPA-001 (disponible en SharePoint)
2. Justifica el motivo (legal, contractual, operacional)
3. EnvÃ­a a data-governance@empresa.com
4. Tiempo de respuesta: 10 dÃ­as hÃ¡biles

El sistema recordarÃ¡ el contexto de tu pregunta anterior
y mantendrÃ¡ la conversaciÃ³n fluida.
```

### 3. CaracterÃ­sticas

âœ… **Memoria de Contexto**: Recuerda preguntas anteriores  
âœ… **ReformulaciÃ³n**: Interpreta preguntas ambiguas  
âœ… **BÃºsqueda SemÃ¡ntica**: Extrae documentaciÃ³n relevante  
âœ… **Sugerencias Relacionadas**: Propone temas seguimiento  
âœ… **MÃ©tricas**: Registra latencia, tokens, coste en AppInsights  

### 4. Salir

```
User: exit
Chat guardado en: outputs/chat-history-2026-05-13.json
Tokens totales: 1,240
Coste total: $0.31
Session guardada en AppInsights
```

---

## Architecture

```
User Input
    â†“
[Context Manager] â†’ Mantiene histÃ³rico de conversaciÃ³n
    â†“
[Query Router] â†’ Â¿Reformular? Â¿Buscar en Ã­ndice? Â¿Seguimiento?
    â†“
[Search Agent] â†’ BÃºsqueda semÃ¡ntica en Azure Search
    â†“
[Context Builder] â†’ Recupera documentos relevantes + histÃ³rico
    â†“
[OpenAI Completion] â†’ Genera respuesta conversacional
    â†“
[Metrics Logger] â†’ AppInsights + local JSON
    â†“
User Response + Suggestions
```

---

## Configuration (`.env`)

```


RAG_CHAT_MAX_HISTORY=10         # Mantener Ãºltimas 10 interacciones
RAG_CHAT_TIMEOUT=60              # Timeout por turno (segundos)
RAG_CHAT_TOP_K=8                 # Documentos recuperados por bÃºsqueda
RAG_CHAT_TEMPERATURE=0.5         # Creatividad (0.3=factual, 0.7=creativo)
RAG_CHAT_MAX_TOKENS=2000         # Max tokens por respuesta
```

---

## Output

Chat session guardada automÃ¡ticamente:

```json
{
  "session_id": "chat-20260513-143022",
  "started_at": "2026-05-13T14:30:22Z",
  "messages": [
    {
      "turn": 1,
      "user_query": "Â¿CuÃ¡l es la polÃ­tica de retenciÃ³n?",
      "search_results": 5,
      "assistant_response": "...",
      "tokens_used": 240,
      "latency_ms": 1850
    }
  ],
  "total_tokens": 1240,
  "total_cost_usd": 0.31,
  "duration_seconds": 180
}
```

---

## vs CLI Script

| Aspecto | CLI | Chat |
|---------|-----|------|
| Latencia | 2s | 5s |
| Coste | $0.02 | $0.05 |
| Queries | Puntuales | ConversaciÃ³n |
| Contexto | Stateless | Multi-turno |
| Uso | BÃºsquedas quick | ExploraciÃ³n profunda |

**Elige Chat cuando necesites seguimiento y contexto.**

