# Weekly Review

## Intended task
Use this prompt at the end of a working week to reflect on what actually happened, not just to list completed tasks. It compares the week's intentions with its outcomes, looks for the reasons behind gaps, surfaces open loops that need a decision, notices what drained or restored energy, and ends with a short set of commitments to carry forward. It borrows the "get clear, get current" spirit of the Getting Things Done weekly review and the start/stop/continue retrospective format, adapted for one person. Planning the coming week in detail is a separate step: use `weekly-planning-routine` right after this, or `personal-planning-agent` for help building the schedule.

## Required context
- **Last week's intentions**: the priorities or plan you set at the start of the week. If you had none, say so; that itself is a finding.
- **What happened**: completed tasks, calendar summary, notes or journal entries, messages that shaped the week. Rough bullets are fine.
- **Open items**: unfinished tasks, waiting-for items, unanswered requests.
- **Energy and wellbeing notes** you are comfortable sharing: sleep, stress, workload, what felt good.
- **Longer-term goals** or quarterly objectives, so the review can check alignment.

Remove other people's private details before pasting; refer to colleagues by role if you prefer.

## Prompt
```text
You are a thoughtful coach helping me run an honest weekly review. Be specific and grounded in what I give you. Do not give generic productivity advice, do not moralise, and do not invent events or numbers. Ask about anything important that is ambiguous instead of guessing.

Week: {{WEEK_DATES}}
What I intended this week:
{{WEEK_INTENTIONS}}

What actually happened (tasks done, calendar, notes):
{{WEEK_ACTIVITY}}

Open loops (unfinished, waiting on others, unanswered):
{{OPEN_LOOPS}}

Energy and wellbeing notes:
{{ENERGY_NOTES}}

Longer-term goals I am working toward:
{{LONGER_TERM_GOALS}}

Run the review in this order:
1. Planned vs actual: for each intention, mark done, partly done, or not done, citing what I wrote. Then list significant work I did that was not planned.
2. Wins: three to five concrete wins, including small ones, and what made each possible.
3. Gaps and causes: for each unmet intention, the most likely cause drawn from my notes (overcommitment, interruptions, unclear next action, waiting on someone, low energy, changed priority). Mark anything you infer as "Possible:".
4. Open loops triage: sort every open loop into do next week, delegate or follow up, renegotiate or decline, park in someday/maybe, or drop. Give the next physical action for each item kept.
5. Energy patterns: what gave and drained energy, and one pattern worth testing next week.
6. Alignment check: how much of the week moved my longer-term goals, and which goal got no attention.
7. Lessons: two or three sentences in the first person that I could reread next month.
8. Carry-forward: at most five commitments for next week, each concrete and finishable, plus one thing to stop or say no to.
9. Questions for me: up to three questions that would make next week's review sharper.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{WEEK_DATES}}` | The week being reviewed, e.g. "3-7 November" | Yes |
| `{{WEEK_INTENTIONS}}` | Priorities or plan set at the start of the week, or "none set" | Yes |
| `{{WEEK_ACTIVITY}}` | Done tasks, calendar summary, notes | Yes |
| `{{OPEN_LOOPS}}` | Unfinished tasks, waiting-for items, unanswered requests | Yes |
| `{{ENERGY_NOTES}}` | Sleep, stress, workload, highs and lows you choose to share | No |
| `{{LONGER_TERM_GOALS}}` | Quarterly or yearly goals for the alignment check | No |

## Output format
Nine short numbered sections with headings. Planned vs actual is a table (`Intention | Status | Evidence`). Open loops triage is a table (`Item | Decision | Next action`). Lessons are written in the first person. Carry-forward commitments are a numbered list of no more than five. The whole review should fit on one screen or two; if it is longer, the input was probably too detailed or the model is padding.

## Example usage
A product manager pastes three intentions (finish the pricing brief, run two customer interviews, clear the review queue), a list of meetings, and notes saying two days were taken over by an escalation. A good review marks the brief as partly done, the interviews as not done with the cause "Possible: scheduling waited on the sales team", credits handling the escalation as unplanned but valuable work, triages eight open loops (two declined, one delegated), notices that afternoons after back-to-back meetings produced nothing, and carries forward four commitments including "book interviews directly via the shared calendar link on Monday morning".

## Customization
- For a team lead, add a section on people: who needs feedback, recognition or a check-in.
- For a lighter weekly ritual, keep only sections 1, 4 and 8.
- Monthly variant: replace the week with the month and add a section on trends across the four weekly reviews.
- If you track time, paste the totals into the activity section and ask for planned-versus-actual hours in section 1.
