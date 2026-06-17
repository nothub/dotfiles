# Security Code Patterns

Go implementation patterns for the OWASP Top 10. Use alongside the `security-and-hardening` skill; see `security-checklist.md` for the review checklist these patterns satisfy.

## Injection (SQL, OS Command)

```go
// BAD: SQL injection via string concatenation
query := fmt.Sprintf("SELECT * FROM users WHERE id = '%s'", userID)
rows, _ := db.Query(query)

// GOOD: Parameterized query (database/sql)
rows, err := db.QueryContext(ctx, "SELECT * FROM users WHERE id = $1", userID)

// GOOD: Named params (modernc.org/sqlite or pgx)
rows, err := db.QueryContext(ctx,
    "SELECT * FROM tasks WHERE user_id = $1 AND status = $2",
    userID, status)
```

## Authentication — Password Hashing

```go
import "golang.org/x/crypto/bcrypt"

const bcryptCost = 12

func hashPassword(plaintext string) (string, error) {
    b, err := bcrypt.GenerateFromPassword([]byte(plaintext), bcryptCost)
    return string(b), err
}

func checkPassword(plaintext, hash string) bool {
    return bcrypt.CompareHashAndPassword([]byte(hash), []byte(plaintext)) == nil
}
```

## XSS — Use html/template

```go
import "html/template"
// NOT "text/template" — text/template does not escape HTML

// html/template escapes all {{ .Field }} values automatically
var tmpl = template.Must(template.ParseFiles("templates/page.html"))

func (h *Handler) Page(w http.ResponseWriter, r *http.Request) {
    tmpl.Execute(w, data) // all data values are HTML-escaped
}

// If you MUST inject trusted HTML (rare), use template.HTML explicitly:
// type safeHTML = template.HTML
// Never cast user-supplied strings to template.HTML
```

## Broken Access Control

```go
func (h *TaskHandler) Update(w http.ResponseWriter, r *http.Request) {
    taskID := r.PathValue("id")
    task, err := h.svc.Get(r.Context(), taskID)
    if err != nil {
        http.Error(w, "not found", http.StatusNotFound)
        return
    }
    userID := userFromContext(r.Context())
    if task.OwnerID != userID {
        http.Error(w, "forbidden", http.StatusForbidden)
        return
    }
    // proceed with update
}
```

## Security Headers Middleware

```go
func securityHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        h := w.Header()
        h.Set("X-Content-Type-Options", "nosniff")
        h.Set("X-Frame-Options", "DENY")
        h.Set("Referrer-Policy", "strict-origin-when-cross-origin")
        h.Set("Strict-Transport-Security", "max-age=63072000; includeSubDomains")
        h.Set("Content-Security-Policy", "default-src 'self'")
        next.ServeHTTP(w, r)
    })
}
```

## Sensitive Data Exposure

```go
// Never return sensitive fields in API responses
type User struct {
    ID           string    `json:"id"`
    Email        string    `json:"email"`
    CreatedAt    time.Time `json:"createdAt"`
    PasswordHash string    `json:"-"` // "-" omits from JSON always
    ResetToken   string    `json:"-"`
}

// Use environment variables for secrets; fail fast if missing
func mustEnv(key string) string {
    v := os.Getenv(key)
    if v == "" {
        log.Fatalf("required env var %s not set", key)
    }
    return v
}
```

## Server-Side Request Forgery (SSRF)

When the server fetches a URL the user influenced — webhooks, "import from URL", link previews — an attacker can aim it at internal services (`localhost`, cloud metadata at `169.254.169.254`, private IPs).

```go
import "net"

func assertSafeURL(rawURL string) (*url.URL, error) {
    u, err := url.Parse(rawURL)
    if err != nil || u.Scheme != "https" {
        return nil, errors.New("https URLs only")
    }
    addrs, err := net.LookupHost(u.Hostname())
    if err != nil {
        return nil, fmt.Errorf("DNS lookup failed: %w", err)
    }
    for _, addr := range addrs {
        ip := net.ParseIP(addr)
        if ip == nil || ip.IsLoopback() || ip.IsPrivate() || ip.IsLinkLocalUnicast() {
            return nil, errors.New("private/reserved address not allowed")
        }
    }
    return u, nil
}

// Use it before fetching:
u, err := assertSafeURL(r.FormValue("webhookURL"))
if err != nil { ... }
resp, err := http.Get(u.String())
```

**TOCTOU caveat:** `net/http` re-resolves DNS at connect time. For high-risk surfaces, bind to the resolved IP directly or put a filtering proxy in front.
