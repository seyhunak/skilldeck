---
name: ux-copy-review
description: Review interface microcopy - buttons, labels, headings, helper text, empty states, error messages, confirmations, notifications, and tooltips - for clarity, actionability, consistency, tone, and fit. Returns a line-by-line table of issues, the rule broken, and a rewrite. Use when reviewing screens, flows, design files, or string files before release, or when users misunderstand or ignore interface text.
---

# UX Copy Review

Interface text is part of the interaction design. Good microcopy tells people where they are, what will happen, and what to do next, in the fewest familiar words. This skill provides a rubric and a procedure for reviewing it systematically rather than by taste.

## When to use

- Reviewing a flow, screen set, or string file before launch.
- Users misunderstand an action, miss a step, or contact support about wording.
- A product has inconsistent terminology across features.
- Error messages are generic ("Something went wrong") and need rewriting.

Not for: long-form marketing or documentation copy, brand voice definition from scratch, or legal and consent text, which should be reviewed by its owner (flag issues instead of rewriting meaning).

## Inputs

- The copy in context: screenshots, design frames, or strings with a note on where each appears. Required; copy without context is reviewed with lower confidence.
- Voice and tone guidelines and a terminology list or glossary. Recommended.
- Audience and locale(s), including whether strings will be translated. Recommended.

## Procedure

1. **Inventory strings by type.** Group them: navigation and headings, buttons and links, form labels and helper text, placeholders, empty states, errors and warnings, confirmations and dialogs, success messages, notifications, tooltips. Each type has different rules.
2. **Check clarity.** Use the user's vocabulary, not internal or technical terms ("workspace" not "tenant"; "couldn't save" not "HTTP 500"). Put the most important words first. Prefer short, common words and active voice. One idea per sentence.
3. **Check actionability by type.**
   - *Buttons and links:* a specific verb describing the outcome ("Save changes", "Send invite", "Delete project"), not "OK", "Submit", or "Click here". The label on a confirmation button matches the action in the dialog title.
   - *Errors:* say what happened, why if useful, and how to fix it, in plain language, without blaming the user ("That card number is incomplete. Check the 16 digits on the front of your card." rather than "Invalid input"). Place errors next to the field they concern.
   - *Empty states:* explain what will appear here, and give the first action to fill it.
   - *Destructive confirmations:* name the object and consequence, state whether it can be undone, and label buttons with the action ("Delete 3 files" / "Keep files").
   - *Labels and helper text:* labels stay visible (placeholder text is not a substitute for a label); helper text states format or constraints before the error occurs.
   - *Success messages:* confirm what happened and, if relevant, what happens next.
4. **Check consistency.** One term per concept across the product; consistent capitalization style (sentence case is the common default); consistent use of "you/your" versus "my"; consistent date, number, and time formats for the locale.
5. **Check tone for the moment.** Neutral and calm for errors and money; lighter tone only where stakes are low. No humor in errors, data loss, payments, or security contexts. Avoid guilt-tripping or manipulative wording ("No thanks, I don't want to save money").
6. **Check fit and localization.** Length suits the component (button labels typically one to three words); avoid concatenated strings and embedded variables that break grammar in other languages; allow for text expansion in translation (some languages run substantially longer than English); avoid idioms.
7. **Check accessibility of copy.** Link and button text makes sense out of context; instructions do not rely solely on color, shape, or position ("click the green button"); icon-only controls have accessible names; reading level suits the audience.
8. **Write rewrites.** For each issue give the original, the problem, the rule it breaks, and a rewrite. Offer at most two alternatives when the right choice depends on product decisions.
9. **Summarize patterns** and propose glossary or style-guide additions.

## Expected output

```markdown
## UX Copy Review: <flow / screen set>

| # | Location | Type | Original | Issue | Rule | Rewrite |
|---|---|---|---|---|---|---|

### Patterns
- ...

### Proposed glossary and style additions
| Term to use | Terms to avoid | Definition |

### Flagged for owner review (legal, pricing, consent)
- ...
```

## Constraints and limitations

- Do not change the meaning of legal, pricing, privacy, or consent text; flag it for its owner.
- Respect the existing voice guide where one is provided; note conflicts rather than overriding it.
- Copy reviewed without visual context may miss layout or truncation issues; say so.
- Rewrites are proposals; for high-traffic surfaces recommend testing alternatives.

## Examples

| Location | Original | Issue | Rewrite |
|---|---|---|---|
| Delete dialog | "Are you sure?" / "OK" / "Cancel" | Does not name object or consequence; vague button | "Delete 'Q3 Plan'? This removes it for everyone and can't be undone." / "Delete plan" / "Keep plan" |
| Upload error | "Error 413" | Technical code, no fix | "This file is larger than 25 MB. Compress it or upload a smaller file." |
| Empty dashboard | "No data" | No guidance | "Your reports will appear here. Connect a data source to create your first report." with button "Connect data source" |
| Signup field | Placeholder only: "Password" | Label disappears on typing; rules unknown | Label "Password", helper text "At least 12 characters" |
