# Component Patterns Quick Reference

Condensed from the WAI-ARIA Authoring Practices Guide (APG) patterns as commonly implemented. APG is advisory; WCAG success criteria are the requirement. Verify details against the current APG for complex widgets.

| Widget | Preferred markup / role | Required states and properties | Keyboard |
|---|---|---|---|
| Button | `<button>` | `aria-pressed` for toggles | Enter, Space |
| Link | `<a href>` | `aria-current="page"` for current nav item | Enter |
| Disclosure | `<button>` controlling a region | `aria-expanded`, optional `aria-controls` | Enter, Space |
| Modal dialog | `<dialog>` with `showModal()`, or `role="dialog"` + `aria-modal="true"` | Name via `aria-labelledby` | Focus moves in, Tab contained, Escape closes, focus returns to trigger |
| Tabs | `role="tablist"`, `tab`, `tabpanel` | `aria-selected`, `aria-controls`, panel `aria-labelledby` | Arrow keys between tabs, Home/End; Tab moves into the panel |
| Menu button (actions) | `<button aria-haspopup="menu">` + `role="menu"`/`menuitem` | `aria-expanded` on button | Arrow keys, Escape closes, Enter activates |
| Site navigation | `<nav>` with a list of links | `aria-current` | Tab between links (no menu roles) |
| Combobox | `role="combobox"` on the input, popup `listbox` | `aria-expanded`, `aria-controls`, `aria-activedescendant` for the highlighted option | Down opens/moves, Enter selects, Escape closes |
| Listbox | `role="listbox"`, `option` | `aria-selected`, `aria-multiselectable` when applicable | Arrow keys, type-ahead |
| Switch | `<button role="switch">` or checkbox | `aria-checked` | Space (and Enter for button) |
| Tooltip | `role="tooltip"` referenced by `aria-describedby` | — | Appears on focus as well as hover; Escape dismisses (1.4.13) |
| Toast / status | Live region (`role="status"` or `aria-live="polite"`) present before the update | — | Must not steal focus; persistent actions also reachable elsewhere |
| Alert | `role="alert"` for urgent, time-sensitive messages only | — | — |
| Data table | `<table>`, `<th scope>`, `<caption>` | `aria-sort` on sortable headers | Standard Tab to controls |
| Accordion | Heading wrapping a button per section | `aria-expanded`, `aria-controls` | Enter, Space; optional arrows |

## Frequent code-level errors

- `onClick` on `div`/`span` without role, `tabindex="0"`, and key handlers. Use `<button>`.
- `aria-label` on non-interactive generic elements (often ignored by assistive tech).
- `aria-hidden="true"` on an element that contains focusable children.
- `outline: none` on `:focus` without a visible `:focus-visible` replacement.
- Live region injected into the DOM at the same time as its message (often not announced).
- Duplicate IDs from repeated components breaking `aria-labelledby` references.
- `role="presentation"` on images that convey information.
- Icons from icon fonts read as unicode characters; hide decorative icons with `aria-hidden="true"`.

## WCAG 2.2 additions relevant to code (Level A/AA)

- 2.4.11 Focus Not Obscured (Minimum) — AA
- 2.5.7 Dragging Movements — AA
- 2.5.8 Target Size (Minimum) — AA
- 3.2.6 Consistent Help — A
- 3.3.7 Redundant Entry — A
- 3.3.8 Accessible Authentication (Minimum) — AA

Note: 4.1.1 Parsing is obsolete and removed in WCAG 2.2.
