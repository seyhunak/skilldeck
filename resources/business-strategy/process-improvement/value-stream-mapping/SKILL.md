---
name: value-stream-mapping
description: Build current-state and future-state value stream maps for a business or delivery process, quantifying process time, wait time, percent complete and accurate, lead time, and flow efficiency, and identifying the eight wastes. Use when a process is slow, handoff-heavy, or full of rework and you need to see where time actually goes before redesigning it.
---

# Value Stream Mapping

A value stream map (VSM) shows every step from a customer request to its fulfilment, with the information flows that trigger work and the time and quality data for each step. Originating in Toyota's material-and-information-flow diagrams and popularised for office and knowledge work by Karen Martin and Mike Osterling, it is the clearest way to show that lead time is dominated by waiting.

## When to use

- A request-to-delivery process (order-to-cash, hire-to-onboard, idea-to-release, claim-to-payment) takes much longer than the work inside it.
- Several teams or systems are involved and nobody sees the whole flow.
- Before choosing improvement or automation investments, to target the real constraint.
- Not for documenting detailed task instructions; use a procedure document for that.

## Inputs

- The value stream's trigger (customer request) and end point (value delivered).
- Step list with the team or role performing each step.
- Per step, measured or estimated: process time (PT, hands-on work), lead time (LT, from work available to work passed on, including waiting), and %C&A (share of outputs the next step can use without correction).
- Volumes, batch sizes, queue sizes (work-in-progress), and the systems used.
- Customer demand rate if known.

## Procedure

1. **Bound the stream.** Write the trigger, the end point, the customer, and the demand rate. Pick one product or request family; mixing families with different paths produces an unreadable map.
2. **List 5-15 macro steps.** Map at the level where work changes hands or systems. Below five steps hides handoffs; above fifteen usually means mapping tasks.
3. **Collect step data.** For each step record PT, LT, %C&A, people/roles, systems, batch size, and WIP. Prefer measured data (timestamps, samples of items walked through the process) over recalled estimates; label estimates. Use medians or typical values and note ranges.
4. **Map information flow.** Show how work is triggered at each step: push (scheduled, batch, email), pull (signal from downstream), or manual chasing. Note approvals and status-check loops.
5. **Calculate the timeline.** Total lead time = sum of LT; total process time = sum of PT; flow efficiency (activity ratio) = total PT / total LT. Rolled %C&A = product of all %C&A values, showing the share of items that pass through without any rework. Knowledge-work flows commonly show low flow efficiency; the specific number matters less than where the waits sit.
6. **Identify waste.** Tag observations with the eight wastes (often remembered as DOWNTIME): Defects, Overproduction, Waiting, Non-utilised talent, Transportation (handoffs of information), Inventory (queues, backlogs), Motion (searching, switching systems), Extra-processing (redundant approvals, re-keying). Mark the largest waits and lowest %C&A steps as "kaizen bursts".
7. **Design the future state.** Ask in order: What does the customer actually need? Which steps can be eliminated or combined? Where can work flow one item at a time instead of in batches? Where can pull or WIP limits replace pushing? Where must quality be built in at the source to raise %C&A? Draw the future map with target PT, LT, and %C&A.
8. **Plan implementation.** Convert the gap into a short list of improvement actions with owner, sequence, and the metric each should move; set a review date to re-measure.

## Expected output

```markdown
## Value Stream: <name> — Current State
Trigger: ... · End: ... · Demand: ... · Data basis: measured / estimated

| # | Step | Role/team | PT | LT | %C&A | Batch/WIP | Trigger type | Waste notes |
|---|---|---|---|---|---|---|---|---|

Totals: Lead time = ... · Process time = ... · Flow efficiency = ...% · Rolled %C&A = ...%

Kaizen bursts: ranked list of largest waits / quality losses.

## Future State
Same table with targets; summary of changes (eliminated, combined, flow/pull changes).

## Implementation plan
| Action | Waste addressed | Owner | Metric | Expected effect | Date |
```

A Mermaid flowchart may accompany the table, but the table is the record of truth.

## Constraints and limitations

- Estimates from memory are often optimistic about waiting time; validate with timestamps or by following real items through ("walking the process").
- Averages hide variation; when lead times are highly skewed report median and a high percentile.
- A VSM shows where time goes, not why; pair it with root-cause analysis before investing.
- Future-state targets are hypotheses until piloted.

## Examples

**Request:** "Map our employee onboarding from signed offer to productive first day."
**Good result:** eight steps from HR, IT, facilities, and the manager; total LT of 15 working days with PT under 6 hours; the largest wait is laptop provisioning queued behind a weekly batch order; rolled %C&A of 52% due to missing information on the offer form. The future state moves to a daily order trigger, a mandatory complete-and-validated offer form, and parallel IT and facilities steps, targeting a 6-day LT.
