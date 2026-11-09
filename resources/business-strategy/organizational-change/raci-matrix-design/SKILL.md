---
name: raci-matrix-design
description: Create or audit a RACI (Responsible, Accountable, Consulted, Informed) matrix for a process, project, or set of recurring decisions, enforcing one Accountable per row and flagging anti-patterns like missing responsibility, too many consulted parties, and overloaded roles. Use when ownership is unclear, decisions stall between teams, a new team or process is being set up, or a reorganisation changes who decides what.
---

# RACI Matrix Design

A RACI matrix lists activities or decisions as rows and roles as columns, with one letter per cell:

- **R — Responsible:** does the work. At least one per row; can be several.
- **A — Accountable:** owns the outcome, approves the work, and answers for it. Exactly one per row.
- **C — Consulted:** gives input before the work is done or the decision is made; two-way communication.
- **I — Informed:** told after the decision or completion; one-way communication.

The Accountable and Responsible can be the same role for small tasks. Variants such as RAPID (Bain) or DACI are better for complex decisions with distinct recommend/agree/decide roles; mention them if the user's problem is mainly about decisions rather than deliverables.

## When to use

- Setting up a new process, team, project, or shared service.
- Reorganisations, mergers, or handoffs where ownership shifts.
- Diagnosing slow decisions, duplicated work, or "I thought you were doing that" failures.
- Not for task-level scheduling; a project plan or ticket system handles who does which task this week.

## Inputs

- The scope: process, project, or decision domain.
- The roles involved (use roles, not names, unless the team is tiny).
- Known activities, deliverables, or recurring decisions, and any existing matrix.
- Pain points: where things stall or are duplicated.

## Procedure

1. **Choose the right rows.** List 10-30 activities, deliverables, or decisions at a consistent level of detail, each starting with a verb ("Approve campaign budget", "Publish release notes"). Rows that are too granular make the matrix unmaintainable; rows that are too broad ("Manage marketing") cannot have one owner. Prioritise decisions and handoffs where problems occur.
2. **Choose the columns.** Use roles or teams. Include external parties and governance bodies if they act. Avoid columns for individuals unless roles are filled by exactly one person.
3. **Assign A first.** For each row, ask who will be held answerable if it goes wrong and who has the authority to approve. Assign exactly one A. If two candidates exist, either split the row into two decisions or escalate the choice.
4. **Assign R.** Identify who actually does the work. If the A cannot name the R, the row is not ready.
5. **Assign C sparingly.** Include only those whose input materially changes the outcome or who hold a veto in practice (legal, security, finance). Every C adds delay; a long C list often hides an unresolved decision right.
6. **Assign I.** Who needs to know to do their own job? Prefer a broadcast channel over a long I list.
7. **Audit rows.** Flag: no A; more than one A; no R; A with no authority or resources; more than three or four Cs (heuristic); every role marked something (no one owns it in practice).
8. **Audit columns.** Flag: a role with many As (bottleneck or overload); a role with no Rs or As (may be unnecessary in this process); a role with only Cs and Is everywhere (check whether its involvement is needed); a role with As but no visibility of the work.
9. **Validate with the people concerned.** A RACI is an agreement, not a decree. List assignments that need confirmation and conflicts that need escalation.
10. **Set maintenance.** Name an owner for the matrix and a review trigger (reorganisation, new process, recurring escalation).

## Expected output

```markdown
## RACI: <scope>
Roles: <list with one-line descriptions>

| Activity / decision | Role 1 | Role 2 | Role 3 | Role 4 | Notes |
|---|---|---|---|---|---|
| Approve ... | A | R | C | I | |

### Audit findings
| Type | Row / column | Issue | Recommended fix |

### Items needing agreement or escalation
### Maintenance owner and review trigger
```

## Constraints and limitations

- The matrix defines intent; behaviour changes only if managers reinforce it and escalation follows it.
- RACI does not capture sequencing, time, or effort; pair it with a process map when flow matters.
- Assignments involving reporting lines or job scope may affect role descriptions and should be agreed with managers and HR.

## Examples

**Scope:** releasing customer-facing product changes.
**Finding:** "Approve release go/no-go" had A for both the engineering manager and the product manager, and seven Cs. The fix split the row into "Confirm release quality" (A: engineering manager) and "Decide release timing" (A: product manager), reduced Cs to QA lead and support lead, and moved marketing and sales to I via the release channel. A column audit showed the head of product held 14 As out of 22 rows, so routine rows were delegated to product managers.
