# Go Interface Patterns

Implementation patterns for designing Go interfaces and types. Use alongside the `api-and-interface-design` skill.

## Separate Input and Output Types

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

## Typed IDs Prevent Mixing

```go
type TaskID string
type UserID string

// Prevents accidentally passing a UserID where a TaskID is expected
func (s *TaskService) Get(ctx context.Context, id TaskID) (*Task, error) { ... }
```

## Use Interfaces for Testability

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
