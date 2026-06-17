# Code Simplification Patterns

Language-specific before/after examples for `code-simplification`. Read the relevant language section when applying simplifications.

## Go

```go
// SIMPLIFY: Redundant error variable
// Before
err := doThing()
if err != nil {
    return err
}
return nil
// After
return doThing()

// SIMPLIFY: Verbose conditional assignment
// Before
var name string
if user.Nickname != "" {
    name = user.Nickname
} else {
    name = user.FullName
}
// After
name := user.FullName
if user.Nickname != "" {
    name = user.Nickname
}

// SIMPLIFY: Manual slice building
// Before
var active []User
for _, u := range users {
    if u.IsActive {
        active = append(active, u)
    }
}
// After (only if the filter logic is simple and reused; otherwise leave it inline)
active := filter(users, func(u User) bool { return u.IsActive })

// SIMPLIFY: Redundant boolean return
// Before
func isValid(s string) bool {
    if len(s) > 0 && len(s) < 100 {
        return true
    }
    return false
}
// After
func isValid(s string) bool {
    return len(s) > 0 && len(s) < 100
}

// SIMPLIFY: Unnecessary intermediate variable
// Before
result, err := compute(x)
if err != nil {
    return nil, err
}
return result, nil
// After
return compute(x)
```

## Python

```python
# SIMPLIFY: Verbose dictionary building
# Before
result = {}
for item in items:
    result[item.id] = item.name
# After
result = {item.id: item.name for item in items}

# SIMPLIFY: Nested conditionals with early return
# Before
def process(data):
    if data is not None:
        if data.is_valid():
            if data.has_permission():
                return do_work(data)
            else:
                raise PermissionError("No permission")
        else:
            raise ValueError("Invalid data")
    else:
        raise TypeError("Data is None")
# After
def process(data):
    if data is None:
        raise TypeError("Data is None")
    if not data.is_valid():
        raise ValueError("Invalid data")
    if not data.has_permission():
        raise PermissionError("No permission")
    return do_work(data)
```
