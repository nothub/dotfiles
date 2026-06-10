---
name: api-and-interface-design
description: Guides stable API and interface design. Use when designing APIs, module boundaries, or any public interface. Use when creating REST endpoints, defining type contracts between modules, or establishing boundaries between services.
---

# API and Interface Design

## Overview

Design stable, well-documented interfaces that are hard to misuse. Good interfaces make the right thing easy and the wrong thing hard. This applies to REST APIs, module boundaries, service interfaces, and any surface where one piece of code talks to another.

## When to Use

- Designing new API endpoints
- Defining module boundaries or contracts between services
- Establishing database schema that informs API shape
- Changing existing public interfaces

## Core Principles

### Hyrum's Law

> With a sufficient number of users of an API, all observable behaviors of your system will be depended on by somebody, regardless of what you promise in the contract.

Every public behavior — including undocumented quirks, error message text, timing, and ordering — becomes a de facto contract once users depend on it.

- **Be intentional about what you expose.** Every observable behavior is a potential commitment.
- **Don't leak implementation details.** If users can observe it, they will depend on it.
- **Plan for deprecation at design time.** See `deprecation-and-migration` for how to safely remove things.

### The One-Version Rule

Avoid forcing consumers to choose between multiple versions of the same dependency or API. Design for a world where only one version exists at a time — extend rather than fork.

### 1. Contract First

Define the interface before implementing it. The interface is the spec.

```go
// Define the contract first
type TaskService interface {
    Create(ctx context.Context, input CreateTaskInput) (*Task, error)
    List(ctx context.Context, params ListParams) (*Page[Task], error)
    Get(ctx context.Context, id TaskID) (*Task, error)
    Update(ctx context.Context, id TaskID, input UpdateTaskInput) (*Task, error)
    Delete(ctx context.Context, id TaskID) error
}
```

### 2. Consistent Error Semantics

Pick one error strategy and use it everywhere. In HTTP APIs, map Go errors to status codes in a single place.

```go
// Sentinel errors for HTTP mapping
var (
    ErrNotFound     = errors.New("not found")
    ErrForbidden    = errors.New("forbidden")
    ErrUnauthorized = errors.New("unauthorized")
)

type ValidationError struct {
    Field   string
    Message string
}
func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// Single mapping function used by all handlers
func httpError(w http.ResponseWriter, err error) {
    var ve *ValidationError
    switch {
    case errors.Is(err, ErrNotFound):
        writeJSON(w, 404, errBody("NOT_FOUND", err.Error()))
    case errors.Is(err, ErrForbidden):
        writeJSON(w, 403, errBody("FORBIDDEN", err.Error()))
    case errors.Is(err, ErrUnauthorized):
        writeJSON(w, 401, errBody("UNAUTHORIZED", err.Error()))
    case errors.As(err, &ve):
        writeJSON(w, 422, errBody("VALIDATION_ERROR", ve.Error()))
    default:
        writeJSON(w, 500, errBody("INTERNAL_ERROR", "something went wrong"))
    }
}
```

HTTP status code mapping:
```
400 → Client sent malformed data (bad JSON, wrong type)
401 → Not authenticated
403 → Authenticated but not authorized
404 → Resource not found
409 → Conflict (duplicate, version mismatch)
422 → Validation failed (semantically invalid)
500 → Server error (never expose internals)
```

### 3. Validate at Boundaries

Trust internal code. Validate where external input enters.

```go
func (h *TaskHandler) Create(w http.ResponseWriter, r *http.Request) {
    var input CreateTaskInput
    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        writeJSON(w, 400, errBody("INVALID_JSON", "malformed request body"))
        return
    }
    if err := input.Validate(); err != nil {
        httpError(w, err)
        return
    }
    // After validation, internal code trusts the types
    task, err := h.svc.Create(r.Context(), input)
    if err != nil {
        httpError(w, err)
        return
    }
    writeJSON(w, 201, task)
}
```

Where validation belongs: HTTP handlers, webhook receivers, external API response parsing, env var loading.

Where it does NOT belong: internal function calls, data that just came from your own DB, between services that share a type contract.

> **Third-party API responses are untrusted data.** Always validate shape and content before using in logic or rendering.

### 4. Prefer Addition Over Modification

Extend interfaces without breaking existing consumers. Add optional fields; don't change or remove existing ones.

```go
// Good: new optional field
type CreateTaskInput struct {
    Title       string `json:"title"`         // existing
    Description string `json:"description,omitempty"` // existing
    Priority    string `json:"priority,omitempty"`    // added later, optional
}

// Bad: changed field type or removed field — breaks existing callers
```

Deprecate fields before removing them.

### 5. Predictable Naming

| Pattern | Convention | Example |
|---------|-----------|---------|
| REST endpoints | Plural nouns, no verbs | `GET /api/tasks`, `POST /api/tasks` |
| Query params | camelCase | `?sortBy=createdAt&pageSize=20` |
| Response fields | camelCase | `{ "createdAt": "...", "taskId": "..." }` |
| Boolean fields | is/has/can prefix | `isComplete`, `hasAttachments` |

## REST API Patterns

### Resource Design

```
GET    /api/tasks              → List tasks
POST   /api/tasks              → Create a task
GET    /api/tasks/:id          → Get a single task
PATCH  /api/tasks/:id          → Partial update
DELETE /api/tasks/:id          → Delete a task

GET    /api/tasks/:id/comments → List comments for a task
POST   /api/tasks/:id/comments → Add a comment
```

### Pagination

All list endpoints must be paginated.

```
GET /api/tasks?page=1&pageSize=20&sortBy=createdAt&sortOrder=desc

Response:
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 142,
    "totalPages": 8
  }
}
```

### Filtering

Use query parameters.

```
GET /api/tasks?status=in_progress&assignee=user123&createdAfter=2025-01-01
```

### Partial Updates (PATCH)

Accept partial objects — only update provided fields.

```
PATCH /api/tasks/123
{ "title": "Updated title" }
→ Only title changes; all other fields preserved
```

## Go Interface Patterns

### Separate Input and Output Types

```go
// Input: what the caller provides
type CreateTaskInput struct {
    Title       string `json:"title"`
    Description string `json:"description,omitempty"`
}

// Output: what the system returns (includes server-generated fields)
type Task struct {
    ID          TaskID    `json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description,omitempty"`
    CreatedAt   time.Time `json:"createdAt"`
    CreatedBy   UserID    `json:"createdBy"`
}
```

### Typed IDs Prevent Mixing

```go
type TaskID string
type UserID string

// Prevents accidentally passing a UserID where a TaskID is expected
func (s *TaskService) Get(ctx context.Context, id TaskID) (*Task, error) { ... }
```

### Use Interfaces for Testability

Define interfaces at the consumer side, not the provider side. This keeps interfaces small and prevents bloat.

```go
// Handler only needs what it uses
type taskGetter interface {
    Get(ctx context.Context, id TaskID) (*Task, error)
}

type TaskHandler struct {
    tasks taskGetter
}
```

## Red Flags

- Endpoints that return different shapes depending on conditions
- Inconsistent error formats across endpoints
- Validation scattered throughout internal code instead of at boundaries
- Breaking changes to existing fields (type changes, removals without deprecation)
- List endpoints without pagination
- Verbs in REST URLs (`/api/createTask`, `/api/getUsers`)
- Third-party API responses used without validation

## Verification

After designing an API:

- [ ] Interface is defined before implementation
- [ ] Every endpoint has typed input and output
- [ ] Error responses follow a single consistent format
- [ ] Validation happens at system boundaries only
- [ ] List endpoints support pagination
- [ ] New fields are additive and optional (backward compatible)
- [ ] No verbs in REST resource URLs
