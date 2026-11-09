---
name: sop-writing
description: Writes standard operating procedures that people follow correctly under real conditions - purpose, scope, roles, prerequisites, numbered steps with expected results and decision points, warnings, records, and version control. Use when documenting a repeatable operational process, onboarding a task to new staff, or converting tribal knowledge into a controlled procedure.
---

# SOP Writing

A standard operating procedure exists so that a trained person can perform a task the same way every time and get the same result, including on a bad day. That makes an SOP different from a how-to article: it has an owner, a version, defined roles, control points, and records that prove it was followed. This skill produces SOPs that are precise enough to audit and simple enough to use at the workstation.

## When to use

- A recurring process (month-end close step, customer refund, server patching, lab sample handling, employee offboarding) depends on one person's memory.
- Errors or inconsistent outcomes trace back to people doing a task differently.
- An audit, certification, or customer requires documented procedures.
- A task is being handed to new staff or another team.

Not appropriate for one-off projects, exploratory work, or policy statements (which say what and why, while SOPs say how). In regulated settings (GMP, clinical, aviation, financial controls) use the organisation's controlled SOP template and approval workflow; this skill helps draft the content, it does not confer compliance.

## Inputs

- The process as currently performed: walkthrough notes, a recording, screenshots, or an interview with the person who does it. Required.
- The process owner and the roles involved.
- Applicable policies, regulations, or standards the procedure must satisfy.
- The organisation's SOP template and numbering scheme, if any.

## Procedure

1. **Define boundaries.** Write the purpose (one sentence on the outcome the procedure ensures), scope (what is included and excluded), the trigger that starts the procedure, and the end state that finishes it.
2. **Name roles, not people.** Use a simple RACI-style list: who performs, who approves, who must be informed. Names change; roles persist.
3. **List prerequisites.** Required access, tools, materials, forms, training, and conditions to check before starting.
4. **Choose the format.** Simple linear task: numbered steps. Task with branches: numbered steps with explicit decision points, or a flowchart plus steps. Long task with many sub-steps: hierarchical steps (1, 1.1, 1.2). Routine task for experienced staff: a checklist version alongside the full SOP.
5. **Write the steps.** One action per step, starting with an imperative verb; name the system, screen, or field exactly; state the expected result after steps where an error would be noticed ("The status changes to Approved"). Keep conditions before actions ("If the amount exceeds the approval limit, send to the Finance Manager").
6. **Mark control points.** Steps that require a check, approval, or second-person verification are labelled, along with what is checked and what evidence is recorded.
7. **Place warnings before the step they apply to,** using a consistent hierarchy (for example DANGER, WARNING, CAUTION, NOTE) where safety or data loss is involved, and say what happens if ignored.
8. **Handle exceptions.** Document the common failure cases: what to do, who to escalate to, and how to record the deviation. Unknown situations default to stop and escalate.
9. **Define records.** What is kept as evidence the procedure was followed (ticket, log entry, signed form), where, and for how long if a retention rule applies.
10. **Add document control.** SOP number, title, version, effective date, owner, approver, review interval, and a revision history table.
11. **Validate by walkthrough.** Have someone who did not write it perform the procedure from the draft, ideally a new or less experienced person, while the author watches silently. Every hesitation or question becomes an edit. Record the walkthrough date.

## Expected output

```markdown
# SOP-<area>-<nnn>: <Title>
| Version | Effective date | Owner | Approver | Review every |
|---|---|---|---|---|

## 1. Purpose
## 2. Scope
In scope: · Out of scope:
## 3. Roles and responsibilities
| Role | Responsibility |
## 4. Prerequisites
## 5. Procedure
1. <Verb> <thing> in <system/location>.
   Expected result: <...>
2. **Control point:** <check> — record <evidence>.
3. If <condition>, go to step 7. Otherwise continue.
## 6. Exceptions and escalation
| Situation | Action | Escalate to |
## 7. Records
| Record | Location | Retention |
## 8. References
## 9. Revision history
| Version | Date | Change | Author |
```

## Constraints and limitations

- Document how the process should be performed, but capture the current real practice first; note where they differ for the owner to resolve.
- Do not invent regulatory requirements, retention periods, or approval limits; leave marked gaps for the owner.
- An SOP is only valid once approved through the organisation's process; drafts must be labelled as such.
- Overly long SOPs are skipped in practice; split by trigger or role when a procedure exceeds about 25 to 30 top-level steps (a heuristic).

## Examples

Vague original: "Process refunds in the billing tool after checking with finance if it's big."

SOP steps:
1. Open the customer's account in the billing system and select **Invoices**.
2. Confirm the invoice is marked **Paid**. If not, stop: refunds apply only to paid invoices.
3. If the refund amount exceeds the refund approval limit [owner to confirm limit], request approval from the Finance Manager in the refunds queue. **Control point:** do not continue without the approval ticket number.
4. Select **Refund**, enter the amount and reason code, and submit. Expected result: invoice status shows **Refunded** and a credit note number appears.
5. Record the credit note number and approval ticket in the customer case.
