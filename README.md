# GOAT AI – AI Coding Assistant (Cursor-Style)

GOAT AI is a **Cursor-style AI coding assistant** that integrates with a **VS Code extension** and a **Rails backend** to provide intelligent code understanding, refactoring, and test generation.

The system implements modern AI coding assistant architecture including:

* Repository indexing (RAG)
* Vector search
* AST-aware retrieval
* Symbol graph indexing
* Dependency graph retrieval
* Context-aware LLM routing
* Secure authentication
* Streaming responses

This architecture is similar to tools like **Cursor**, **Copilot**, and modern AI code editors.

---

# Architecture Overview

```
VSCode Extension
      |
      | HTTP API
      v
Rails Backend
      |
      | RAG Retrieval
      v
Vector + Symbol Graph Index
      |
      v
LLM Router
      |
      v
LLM Provider (Ollama / OpenAI / Anthropic)
```

---

# Key Features

## AI Coding Tasks

Supported tasks:

* Explain code
* Refactor code
* Generate tests
* Debug code
* Suggest improvements

Example:

```
Explain this function
Refactor this controller
Generate RSpec tests
```

---

# Repository Indexing (RAG)

The system scans the entire repository and stores embeddings.

Indexed data includes:

* file content
* semantic chunks
* code symbols
* dependency relationships

This enables AI to retrieve **relevant repository context** before answering.

---

# AST + Symbol Graph Retrieval

Instead of only using text embeddings, GOAT AI builds a **code-aware symbol graph**.

Indexed symbols include:

```
classes
modules
methods
functions
```

Dependencies include:

```
method calls
imports
inheritance
usage relationships
```

This enables queries like:

```
Where is this method used?
What calls this service?
Explain this controller and dependencies
```

---

# Context Assembly (Cursor-Style)

Before calling the LLM, the backend constructs a **rich context block**.

Context includes:

```
Selected code
Related repository files
Symbol graph relationships
Dependency tree
Chat history
```

Example prompt structure:

```
SYSTEM INSTRUCTIONS

TASK INSTRUCTIONS

RELATED REPOSITORY CODE

CURRENT FILE

SELECTED CODE

CHAT HISTORY
```

---

# Context-Aware LLM Routing

Different tasks use different models.

Example routing:

```
Explain        → Fast model
Refactor       → Smart model
Generate tests → Smart model
Autocomplete   → Ultra fast model
```

Router also considers:

```
prompt size
code complexity
repo context size
```

This improves performance and reduces cost.

---

# Vector Search

Repository embeddings are stored in the database.

Search flow:

```
User selects code
↓
Embedding generated
↓
Vector similarity search
↓
Top relevant chunks retrieved
↓
Passed into prompt context
```

---

# Checksum-Based Incremental Indexing

To prevent re-indexing unchanged files:

```
File checksum stored
↓
File saved
↓
Checksum compared
↓
Index only if changed
```

This makes indexing extremely fast.

---

# Authentication (Secure)

Authentication uses **JWT tokens**.

Flow:

```
VSCode login
↓
Rails generates JWT
↓
VSCode stores token in SecretStorage
↓
Token sent with every request
```

Authorization header:

```
Authorization: Bearer <token>
```

Each user has isolated:

```
repositories
embeddings
symbol graphs
chat sessions
```

---

# Streaming LLM Responses

AI responses are streamed using:

```
Server Sent Events (SSE)
```

Benefits:

* faster responses
* real-time token streaming
* better UX

---

# Folder Structure

```
backend/
  app/
    controllers/
      api/
        chats_controller.rb
        rag_controller.rb
        stream_controller.rb

    models/
      user.rb
      repository.rb
      repo_file.rb
      code_embedding.rb
      symbol.rb
      symbol_dependency.rb
      chat_session.rb
      message.rb

    services/
      llm/
        client.rb
        router.rb
        prompt_builder.rb

      rag/
        repo_indexer.rb
        context_assembler.rb
        checksum_service.rb
        ast_parser.rb
        symbol_indexer.rb
        dependency_extractor.rb
        retriever.rb

      embeddings/
        client.rb

      auth/
        jwt_service.rb

    jobs/
      repo_index_job.rb

vscode-extension/
  src/
    extension.ts
    commands/
      indexRepository.ts
      askAI.ts
    auth/
      tokenManager.ts
    api/
      client.ts
    indexing/
      autoIndexer.ts
```

---

# Database Schema

## users

```
id
email
api_key
created_at
```

## repositories

```
id
user_id
repo_path
```

## repo_files

```
id
repository_id
file_path
checksum
last_indexed_at
```

## code_embeddings

```
id
user_id
repository_id
repo_file_id
content
embedding
```

## symbols

```
id
user_id
repository_id
repo_file_id
name
symbol_type
start_line
end_line
```

## symbol_dependencies

```
id
repository_id
source_symbol_id
target_symbol_id
dependency_type
```

---

# Setup Guide

## 1 Install Dependencies

Backend:

```
bundle install
```

VSCode extension:

```
npm install
```

---

# 2 Environment Variables

Create `.env`

```
LLM_PROVIDER=ollama
OLLAMA_URL=http://localhost:11434

JWT_SECRET=your_secret

GOATAI_API_KEY=dev_key
```

---

# 3 Run Rails Server

```
rails server
```

---

# 4 Install VSCode Extension

From extension folder:

```
npm run compile
```

Launch in development:

```
F5
```

---

# 5 Index Repository

Run command in VSCode:

```
GOAT AI: Index Repository
```

Or automatic indexing occurs when saving files.

---

# 6 Supported LLM Providers

Provider-agnostic architecture supports:

```
Ollama
OpenAI
Anthropic
```

Example Ollama models:

```
deepseek-coder
codellama
qwen2.5-coder
```

---

# Example Workflow

### Step 1

User selects code in VSCode.

### Step 2

Extension sends request:

```
POST /api/chats/message
```

### Step 3

Backend builds context:

```
selected code
vector search results
symbol graph dependencies
chat history
```

### Step 4

LLM router selects model.

### Step 5

Response streamed back to VSCode.

---

# Future Improvements

Potential upgrades:

### Hybrid Retrieval

```
vector search
symbol graph traversal
git history
```

### Ranking Model

Use reranker for better context selection.

### Multi-file edits

Enable AI to edit multiple files automatically.

### Long context models

Support 1M+ token models.

### Codebase map

Provide high level architecture summary.

---

# Goal

Build a **fully open-source Cursor-style AI coding assistant** with:

* modern RAG architecture
* AST-aware retrieval
* scalable indexing
* multi-LLM support

---
