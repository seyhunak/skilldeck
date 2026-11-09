---
name: user-story-writing
description: Write and refine user stories that satisfy INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable) and split oversized stories or epics into thin vertical slices using established splitting patterns. Use when turning requirements, PRDs, or feature ideas into backlog items, when stories are too large to finish in a sprint, or when a backlog needs a quality pass before refinement.
---

# User Story Writing

A user story is a placeholder for a conversation about a small piece of user value, not a miniature specification. Good stories are vertical slices: each one delivers something observable to a user or customer, touching every layer needed, rather than a horizontal technical layer such as "build the API".

## When to use

- Converting a PRD, feature spec, or meeting notes into backlog items.
- Breaking an epic into stories a team can complete within an iteration.
- Reviewing existing stories before refinement or estimation.
- Rewriting technical tasks disguised as stories.

Not for: pure technical tasks with no user-facing outcome (write them as tasks or enablers with a stated purpose), or for detailed acceptance criteria (pair with a Given/When/Then skill such as `acceptance-criteria-gherkin`).

## Inputs

- Source material: requirement, PRD section, feature description, or existing stories. Required.
- User roles or personas the product serves. Recommended.
- Team context: typical iteration length and what "small" means for them. Optional.

## Procedure

1. **Identify roles and goals.** List the distinct user roles involved (be specific: "workspace admin", not "user") and what each is trying to achieve.
2. **Draft stories in a consistent format.** Default: *As a [role], I want [capability], so that [benefit].* The "so that" clause states the real value; if you cannot write it, question whether the story is needed. Alternative job-story form when context matters more than role: *When [situation], I want to [motivation], so I can [outcome].*
3. **Test each story against INVEST.**
   - Independent: can be delivered without waiting for another story in the same batch (some dependency is normal; flag strong coupling).
   - Negotiable: describes the need, not a locked-in UI or implementation.
   - Valuable: a user or customer would notice and care.
   - Estimable: the team understands it well enough to size; unknowns become a time-boxed spike.
   - Small: fits comfortably in one iteration; a common heuristic is a few days of team effort.
   - Testable: you can state how to verify it is done.
4. **Split stories that are too big.** Try these patterns in order and keep each slice valuable:
   - Workflow steps: deliver the simplest end-to-end path first, then later steps.
   - Business rule variations: one rule per story (standard discount first, then tiered).
   - Data variations: one data type or source first (CSV import before Excel).
   - Interface variations: one platform or input method first.
   - Happy path versus edge cases: core success first, then errors and exceptions.
   - Major effort: deliver the hard core once, then cheap extensions.
   - Simple versus complex: a basic version first, refinement later.
   - Defer performance: make it work, then make it fast, when that is acceptable.
   - Spike: when uncertainty blocks estimation, a time-boxed investigation story with a learning goal.
   Avoid splitting by technical layer (front end, back end, database); those slices deliver no user value alone.
5. **Add acceptance criteria hooks.** For each story list three to six bullet conditions of satisfaction, or hand off to Given/When/Then criteria.
6. **Check the set.** Ensure the stories together cover the requirement, with no gaps or duplicates, and order them so the first slice delivers a usable thin path.
7. **Note open questions** that the team must answer in refinement.

## Expected output

```markdown
### Epic: <name> — <goal>
| ID | Story | INVEST notes | Split pattern used | Priority |
|---|---|---|---|---|
| S1 | As a <role>, I want <capability>, so that <benefit>. | Small; depends on none | Workflow: first step | Must |

#### S1 conditions of satisfaction
- ...

**Open questions:** ...
**Suggested slice order:** S1 → S3 → S2 ...
```

## Constraints and limitations

- Do not invent roles, rules, or data the source does not support; list them as questions.
- Keep UI specifics out of the story text unless the UI is the value (for example an accessibility requirement).
- Size judgements are relative and team-specific; do not assign story points unless the user provides a reference scale.
- Compliance and security requirements become explicit stories or constraints, never implicit.

## Examples

Original: "As a user, I want to import contacts so that I can use the CRM." Too large and vague.

Split by data and workflow variations:
- S1: As a sales rep, I want to upload a CSV of contacts with name and email so that I can start outreach without retyping them.
- S2: As a sales rep, I want to map my CSV columns to contact fields so that files from other tools import correctly.
- S3: As a sales rep, I want duplicate contacts flagged during import so that I do not email the same person twice.
- S4: As a sales rep, I want to import from Excel files so that I can use exports from our old system.

S1 is a thin, testable end-to-end slice; S2-S4 add value independently and can be reprioritized.
