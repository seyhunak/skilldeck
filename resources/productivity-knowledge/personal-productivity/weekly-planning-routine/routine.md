# Weekly Planning Routine

## Objective
Produce a plan for the coming week that fits your real capacity. In about 45-60 minutes you clear your capture points, list what is already committed, calculate how many focus hours you truly have, pick a small number of outcomes that fit, and place them on the calendar as protected blocks with buffers. You finish knowing what you will do, what you will not do, and what you need to renegotiate with others. The routine pairs naturally with a reflection step beforehand, such as `weekly-review-prompt`, which supplies lessons and carry-forward commitments.

## Trigger
Run it once a week at a consistent time, commonly Friday afternoon or Monday morning before messages start, and again mid-week if a major disruption (an incident, illness, a surprise deadline) invalidates the plan. It is a personal routine you lead; an assistant such as `personal-planning-agent` may help draft the plan, but nothing is scheduled or sent without your approval.

## Prerequisites
- Access to your calendar, task manager, and main inboxes (email, chat, notes).
- Your longer-term goals or quarterly objectives, so outcomes can be checked for alignment.
- The output of last week's review if you did one.
- An uninterrupted block of time: notifications off, door closed.

## Inputs
- Required: next week's calendar, current task list, carry-forward commitments, deadlines due in the next two weeks.
- Optional: last week's review, team or project plans, personal commitments (appointments, travel), energy patterns you have noticed (for example, mornings are your best focus time).

## Steps
1. **Clear capture points (10-15 minutes).** Process inboxes, notes and loose papers to the point where every item is either a task in your list, a calendar entry, reference material, delegated, or deleted. Do not do the tasks now unless they take under about two minutes. The `email-triage-agent` can help sort a large inbox into categories, but you decide what to answer.
2. **List hard commitments.** From the calendar, write down meetings, appointments, travel and deadlines for the week. Mark which meetings you could decline, shorten or attend asynchronously, and decide now rather than on the day.
3. **Calculate capacity.** For each day, take working hours, subtract meetings, then subtract a buffer for interruptions, email and context switching. A reasonable starting heuristic is 20-30% of the remaining time, more in reactive roles; adjust it based on what your past weeks show. The result is your available focus hours. Write the weekly total down; it is the budget you plan against.
4. **Gather candidates.** Combine carry-forward commitments, near-term deadlines, goal-related work, and requests you have accepted. For each candidate, estimate effort in hours and note whether it needs deep focus or can fit in fragments.
5. **Choose outcomes.** Select up to three outcomes that matter most this week, phrased as finished results ("pricing brief sent for review") rather than activities ("work on pricing"). Check each against your goals and deadlines. Sum their estimates and compare with your focus-hour budget. If they exceed roughly 70% of it, cut or shrink scope; estimates are usually optimistic.
6. **Time-block.** Place deep-focus blocks for the outcomes into your best-energy hours, ideally 90-120 minute blocks, earliest in the week so slippage still leaves time. Batch shallow tasks (email, admin, approvals) into one or two fixed slots per day. Leave at least one unscheduled buffer block mid-week.
7. **Plan the renegotiations.** For anything that does not fit, decide: defer with a new date, delegate, reduce scope, or decline. Draft the short messages needed to tell the affected people, and keep them as drafts until you review them.
8. **Prepare Monday.** Write the first concrete action for Monday's first focus block so you can start without deliberation. Make sure files, access or people needed for that block are ready.
9. **Write the one-page plan.** Record the outcomes, the focus-hour budget, the blocks, the renegotiations, and one thing you will say no to. Keep it where you will see it daily.
10. **Daily check (5 minutes per day).** Each morning compare the day with the plan, move blocks rather than delete them when disrupted, and note what knocked the plan off course for next week's review.

## Decision points
- If available focus hours are below about 8 for the week (a heuristic; adjust to your role), choose one outcome only and treat everything else as maintenance.
- If a meeting has no agenda or clear role for you, propose async input or decline instead of attending by default.
- If an outcome's estimate is larger than a single day's focus time, split it and commit only to the first finishable piece.
- If a new urgent request arrives mid-week, explicitly swap it with a planned item of similar size rather than adding it on top, and tell the affected person.
- If the same outcome has carried forward for three weeks, either break it down, schedule it first thing Monday, or consciously drop it.

## Expected output
A one-page weekly plan:

```text
Week of: <dates>       Focus-hour budget: 14 h (after meetings and 25% buffer)
Outcomes (est.):
  1. Pricing brief sent for review (5 h)
  2. Two customer interviews completed and notes shared (3 h)
  3. Q4 hiring plan draft to manager (2 h)
Planned load: 10 h of 14 h = 71%  -> trimmed outcome 3 to a first draft
Focus blocks: Mon 09:00-11:00 brief; Tue 09:00-10:30 interviews; Wed 14:00-15:30 buffer ...
Shallow slots: daily 11:30-12:00 and 16:30-17:00
Renegotiate: vendor review moved to next week (draft message ready); declined optional sync
Say no to: new side project requests until Friday
Monday first action: open brief outline, write the pricing options table
```

## Validation checklist
- [ ] All capture points are processed to empty or to a clearly deferred state.
- [ ] Focus-hour budget is calculated from the real calendar, including a buffer.
- [ ] No more than three outcomes, each phrased as a finished result with an estimate.
- [ ] Planned outcome effort is at or below roughly 70% of the focus-hour budget.
- [ ] Each outcome has at least one calendar block, and a buffer block exists.
- [ ] Every item that does not fit has a decision and, where needed, a drafted message.

## Human approval
You decide the outcomes, what gets dropped, and which meetings to decline. An assistant may propose a schedule and draft messages, but creating, moving or declining calendar events, sending messages, or reassigning tasks to other people requires your explicit approval for each action. Commitments involving other people, such as delegation or deadline changes, should be confirmed with them directly rather than assumed.
