---
name: frontend-ui-engineering
description: Build web UIs with semantic HTML, plain CSS, and vanilla JS. Use when building or modifying user-facing interfaces. No frameworks, no build step.
---

# Frontend UI Engineering

## Overview

Build functional web interfaces using semantic HTML, plain CSS, and vanilla JS. The page must work without JS where possible. No framework, no bundler, no npm.

Default stack: semantic HTML (server-rendered) · CSS custom properties · vanilla JS ES modules

## HTML: Use the Right Element

Prefer the element that matches the content.

```html
<!-- Structure: header, nav, main, aside, footer, section, article -->
<!-- Content:   h1–h6 (one h1, in order), p, ul, ol, dl, figure, time -->
<!-- Action:    button (not div onclick), a href, details, dialog -->
<!-- Forms:     form, fieldset, legend, label, input, select, textarea -->
```

Every form input has a visible `<label>` linked by `for`/`id`. Icon-only buttons need `aria-label`.

## CSS: Custom Properties

Define a scale at the root; use it everywhere. No arbitrary pixel values.

```css
:root {
  --space-1: 0.25rem; --space-2: 0.5rem; --space-4: 1rem; --space-8: 2rem;
  --text-sm: 0.875rem; --text-base: 1rem; --text-lg: 1.125rem;
  --color-text: #1a1a1a; --color-bg: #ffffff; --color-border: #e5e7eb;
  --color-accent: #2563eb;
}
```

Use grid and flexbox for layout. Mobile-first with `min-width` media queries.

## JS: Progressive Enhancement

The page must work without JS. JS adds behavior, not content.

- Render content server-side. Don't fetch HTML with JS.
- Use `fetch` (not Axios), event delegation on stable ancestors, native `<dialog>`.
- Prefer URL state and form fields over client-side state machines.

```js
// Event delegation: one listener on a stable parent
document.querySelector('#list').addEventListener('click', (e) => {
  const btn = e.target.closest('[data-action]');
  if (!btn) return;
  handleAction(btn.dataset.action, btn.dataset.id);
});
```

## Accessibility Basics

Semantic HTML gives you most of this for free. Minimal extra work needed.

**Keyboard navigation** — `<button>`, `<a>`, `<input>`, `<select>`, `<textarea>` are all keyboard-focusable by default. Tab order follows DOM order, so keep DOM order aligned with the visual layout. Never use `tabindex > 0`.

**Screen readers** — headings (`h1`–`h6`), lists, landmark elements (`<nav>`, `<main>`, `<footer>`), and `<label>` associations are all announced correctly by screen readers when you use the right element. Two things to add manually: `aria-label` on icon-only buttons, and `aria-live="polite"` on regions that update dynamically without a page load.

**Contrast** — text must be readable on both light and dark backgrounds:

| Context | Minimum ratio | Target ratio |
|---|---|---|
| Body text | 4.5:1 (WCAG AA) | 7:1 (WCAG AAA) |
| Large text (≥18px or ≥14px bold) | 3:1 | 4.5:1 |
| UI components, icons | 3:1 | — |

Light mode anchor: `#1a1a1a` on `#ffffff` = 19:1. Dark mode anchor: `#e5e7eb` on `#111827` = 14:1. Muted/secondary text still needs 4.5:1 minimum. Check ratios in browser devtools (Accessibility panel) or with the [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/).

## No Build Step by Default

Don't introduce a bundler or package manager without a concrete reason.

```html
<script type="module" src="/static/app.js"></script>
```

## Verification

- [ ] Page renders and is usable with JS disabled
- [ ] All interactive elements reachable by keyboard (Tab through the page)
- [ ] Every form input has a visible, associated label
- [ ] Heading levels are sequential, one `<h1>` per page
- [ ] No `<div onclick>` where a `<button>` or `<a>` would work
- [ ] No arbitrary pixel values — uses the spacing/type scale
