# Accessibility Checklist

Quick reference for accessible web interfaces. Use alongside the `frontend-ui-engineering` skill.

**Prefer semantic HTML over ARIA.** Native elements (`<button>`, `<nav>`, `<label>`, `<input>`, `<dialog>`) come with built-in roles, keyboard behavior, and screen reader support for free. Reach for ARIA only when no native element can express the semantics.

## Keyboard Navigation
- [ ] All interactive elements focusable via Tab key
- [ ] Focus order follows visual/logical order
- [ ] Focus is visible — style the outline, never remove it
- [ ] Custom widgets support keyboard (Enter to activate, Escape to close)
- [ ] No keyboard traps
- [ ] Skip-to-content link visible on keyboard focus
- [ ] Modals trap focus while open, return focus on close

## Screen Reader Basics
- [ ] All images have `alt` text (`alt=""` for decorative images)
- [ ] Every form input has an associated `<label>` or `aria-label`
- [ ] Heading hierarchy is logical (one `<h1>`, no skipped levels)
- [ ] Dynamic content changes announced via `aria-live` regions
- [ ] Buttons and links have descriptive text (not "click here")

## Visual
- [ ] Text contrast ≥ 4.5:1 (normal text) or ≥ 3:1 (large text ≥ 18px)
- [ ] UI component contrast ≥ 3:1 against background
- [ ] Color is not the only way to convey information
- [ ] Text resizable to 200% without breaking layout

## Forms
- [ ] Every input has a visible label
- [ ] Required fields indicated (not by color alone)
- [ ] Error messages are specific and associated with the field
- [ ] Error state visible beyond color (icon, text, or border)
- [ ] Known fields use `autocomplete` (e.g. `type="email" autocomplete="email"`)

## Common HTML Patterns

### Buttons vs Links

```html
<!-- Actions → <button> -->
<button type="button">Delete Task</button>

<!-- Navigation → <a> -->
<a href="/tasks/123">View Task</a>

<!-- Never use div/span for interactive elements -->
<div onclick="...">Delete</div>  <!-- not focusable, no keyboard support -->
```

### Form Labels

```html
<!-- Explicit association -->
<label for="email">Email address</label>
<input id="email" type="email" required autocomplete="email" />

<!-- Wrapping (implicit) -->
<label>
  Email address
  <input type="email" required />
</label>

<!-- When no visible label is possible -->
<input type="search" aria-label="Search tasks" />
```

### Landmark Regions

```html
<header>...</header>
<nav aria-label="Main navigation">...</nav>
<main>...</main>
<footer>...</footer>

<!-- Status and error messages -->
<div role="status" aria-live="polite">Task saved</div>
<div role="alert">Error: Title is required</div>

<!-- Modal dialogs — prefer native <dialog> -->
<dialog aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Delete</h2>
</dialog>
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| `div` or `span` as button | Not focusable, no keyboard support | Use `<button>` |
| Missing `alt` text | Images invisible to screen readers | Add descriptive `alt` or `alt=""` for decorative |
| Color-only states | Invisible to color-blind users | Add icons, text, or border changes |
| Removing focus outlines | Keyboard users can't see where they are | Style the outline, never `outline: none` |
| Empty links or buttons | Announced with no description | Add visible text or `aria-label` |
| `tabindex > 0` | Breaks natural tab order | Use only `tabindex="0"` or `tabindex="-1"` |
| Autoplaying media | Disorienting, can't be stopped | Add controls, never autoplay |
