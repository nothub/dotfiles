---
name: security-and-hardening
description: Harden code against vulnerabilities. Use when handling user input, authentication, sessions, data storage, or external integrations.
---

# Security and Hardening

## Overview

Security-first development. Treat every external input as hostile, every secret as sacred, every authorization check as mandatory. Security isn't a phase — it's a constraint on every line of code that touches user data, authentication, or external systems.

## When to Use

- Building anything that accepts user input
- Implementing authentication or authorization
- Storing or transmitting sensitive data
- Integrating with external APIs or services
- Adding file uploads, webhooks, or callbacks
- Handling payment or PII data

## Process: Threat Model First

Controls bolted on without a threat model are guesses. Before hardening, spend five minutes thinking like an attacker:

1. **Map trust boundaries.** Where does untrusted data enter? HTTP requests, form fields, file uploads, webhooks, third-party APIs, message queues, **LLM output**. Every boundary is attack surface.
2. **Name the assets.** Credentials, PII, payment data, admin actions, money movement.
3. **Run STRIDE over each boundary:**

| Threat | Ask | Typical mitigation |
|---|---|---|
| **S**poofing | Can someone impersonate a user/service? | Authentication, signature verification |
| **T**ampering | Can data be altered in transit or at rest? | Parameterized queries, HTTPS, integrity checks |
| **R**epudiation | Can an action be denied later? | Audit logging of security events |
| **I**nformation disclosure | Can data leak? | Encryption, field allowlists, generic errors |
| **D**enial of service | Can it be overwhelmed? | Rate limiting, input size caps, timeouts |
| **E**levation of privilege | Can a user gain rights they shouldn't? | Authorization checks, least privilege |

## The Three-Tier Boundary System

### Always Do (No Exceptions)

- **Validate all external input** at the system boundary (HTTP handlers)
- **Parameterize all database queries** — never concatenate user input into SQL
- **Use `html/template`** for HTML rendering — never `text/template` (no escaping)
- **Use HTTPS** for all external communication
- **Hash passwords** with bcrypt/scrypt/argon2 (never store plaintext)
- **Set security headers** on every response (see below)
- **Run `govulncheck ./...`** before every release

### Ask First (Requires Human Approval)

- Adding new authentication flows or changing auth logic
- Storing new categories of sensitive data (PII, payment info)
- Adding new external service integrations
- Changing CORS configuration
- Adding file upload handlers
- Modifying rate limiting or throttling
- Granting elevated permissions or roles

### Never Do

- **Never commit secrets** to version control (API keys, passwords, tokens)
- **Never log sensitive data** (passwords, tokens, full credit card numbers)
- **Never trust client-side validation** as a security boundary
- **Never expose stack traces** or internal error details to users
- **Never store session tokens in client-readable storage** (use httpOnly cookies)

## OWASP Top 10 Prevention Patterns

Go implementation patterns for injection, password hashing, XSS, broken access control, security headers, sensitive data exposure, and SSRF live in `references/security-code-patterns.md` — read it when implementing any of these controls.

## Input Validation at Boundaries

Validate at HTTP handlers. Trust internal code.

```go
type CreateTaskInput struct {
    Title       string `json:"title"`
    Description string `json:"description,omitempty"`
    Priority    string `json:"priority,omitempty"`
}

func (i *CreateTaskInput) Validate() error {
    i.Title = strings.TrimSpace(i.Title)
    if i.Title == "" {
        return &ValidationError{Field: "title", Message: "required"}
    }
    if len(i.Title) > 200 {
        return &ValidationError{Field: "title", Message: "max 200 characters"}
    }
    switch i.Priority {
    case "", "low", "medium", "high":
    default:
        return &ValidationError{Field: "priority", Message: "must be low, medium, or high"}
    }
    return nil
}

func (h *Handler) CreateTask(w http.ResponseWriter, r *http.Request) {
    var input CreateTaskInput
    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        writeError(w, 400, "invalid JSON")
        return
    }
    if err := input.Validate(); err != nil {
        writeError(w, 422, err.Error())
        return
    }
    // input is now trusted
}
```

## File Upload Safety

```go
const maxUploadSize = 5 << 20 // 5 MB

var allowedTypes = map[string]bool{
    "image/jpeg": true,
    "image/png":  true,
    "image/webp": true,
}

func (h *Handler) Upload(w http.ResponseWriter, r *http.Request) {
    r.Body = http.MaxBytesReader(w, r.Body, maxUploadSize)
    if err := r.ParseMultipartForm(maxUploadSize); err != nil {
        http.Error(w, "file too large", http.StatusBadRequest)
        return
    }
    file, _, err := r.FormFile("file")
    if err != nil {
        http.Error(w, "invalid upload", http.StatusBadRequest)
        return
    }
    defer file.Close()

    // Detect type from magic bytes — don't trust the extension or Content-Type header
    buf := make([]byte, 512)
    if _, err := file.Read(buf); err != nil {
        http.Error(w, "cannot read file", http.StatusBadRequest)
        return
    }
    if !allowedTypes[http.DetectContentType(buf)] {
        http.Error(w, "file type not allowed", http.StatusBadRequest)
        return
    }
}
```

## Rate Limiting

```go
import "golang.org/x/time/rate"

// Per-IP limiter map (simplest approach; use a proper store for distributed systems)
var (
    mu       sync.Mutex
    limiters = map[string]*rate.Limiter{}
)

func getLimiter(ip string) *rate.Limiter {
    mu.Lock()
    defer mu.Unlock()
    if l, ok := limiters[ip]; ok {
        return l
    }
    l := rate.NewLimiter(rate.Every(time.Minute/20), 5) // 20/min, burst 5
    limiters[ip] = l
    return l
}

func rateLimitMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        ip, _, _ := net.SplitHostPort(r.RemoteAddr)
        if !getLimiter(ip).Allow() {
            http.Error(w, "too many requests", http.StatusTooManyRequests)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

## Secrets Management

```
.env files:
  ├── .env.example  → Committed (template, placeholder values only)
  └── .env          → NOT committed (real secrets)

.gitignore must include:
  .env
  *.pem
  *.key
```

If a secret is ever committed, **rotate it first**, then purge history. Assume it's compromised the moment it hits a remote.

```bash
# Check before committing
git diff --cached | grep -iE "password|secret|api_key|token|PRIVATE"
```

## Supply Chain

Go's module system provides integrity checking by default:

```bash
# go.sum is the lockfile — always commit it
# Reproducible installs in CI:
go mod download
go mod verify       # verify all modules match go.sum checksums

# Scan for known vulnerabilities
govulncheck ./...   # checks your actual call graph, not just go.sum

# Review new dependencies before adding:
# - Is it maintained? (last commit, open issues)
# - Does it pull a large dependency tree?
# - Does it run init() or go:generate that executes code?
```

## Securing AI / LLM Features

LLM output is **untrusted data** — validate and encode it exactly as you would raw user input.

```go
// BAD: trusting model output as a query or HTML
query := fmt.Sprintf("SELECT %s FROM tasks", llmOutput)  // SQL injection via model
w.Write([]byte(llmOutput))                                // XSS if rendered as HTML

// GOOD: parse → validate → use safely
var intent struct {
    Action string `json:"action"`
    TaskID string `json:"task_id"`
}
if err := json.Unmarshal([]byte(llmOutput), &intent); err != nil {
    return errors.New("unexpected model output")
}
if !allowlistedActions[intent.Action] {
    return errors.New("action not permitted")
}
// Render text output safely via html/template, not raw Write
```

OWASP LLM Top 10 risks in scope:
- **LLM01 Prompt Injection**: untrusted text in context can carry instructions; enforce permissions in code
- **LLM05 Improper Output Handling**: model output into `eval`, SQL, shell, or HTML = injection
- **LLM06 Excessive Agency**: scope tools to minimum, require confirmation for destructive actions
- **LLM10 Unbounded Consumption**: cap tokens, rate, and recursion depth

## Red Flags

- User input passed directly to `db.Query` without parameterization
- Secrets in source code or commit history
- Handlers without authorization checks
- Using `text/template` to render HTML (no escaping)
- No rate limiting on authentication endpoints
- Server fetches user-supplied URLs without validation (SSRF)
- LLM output passed into a query, template, or shell command
- Stack traces or internal errors returned to the client

## Reference

Before finishing a security review, read `references/security-checklist.md` for a full OWASP Top 10 + LLM security checklist.

## Verification

- [ ] `govulncheck ./...` — no known vulnerabilities
- [ ] No secrets in source code or git history
- [ ] All user input validated at handler boundaries
- [ ] Auth and authz checked on every protected endpoint
- [ ] Security headers present on responses
- [ ] Error responses don't expose internal details
- [ ] Rate limiting active on auth endpoints
- [ ] Server-side URL fetches validated against allowlist
- [ ] LLM output validated and encoded before use (if AI features present)
