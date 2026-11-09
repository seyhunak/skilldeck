---
name: meeting-notes-structuring
description: Structures meeting notes into a consistent, scannable record - header, purpose, decisions, action items, open questions, and per-topic notes - from raw notes, transcripts, or memory. Use when writing up any meeting, standardising notes across a team, or preparing an agenda that maps cleanly onto the notes afterwards.
---

# Meeting Notes Structuring

Good meeting notes are read by people who were not there and by attendees three weeks later who no longer remember. Both groups need the outcomes first and the discussion second. This skill imposes one consistent layout so that every set of notes answers the same questions in the same place.

## When to use

- Writing up a meeting from raw notes, a transcript, or a chat log.
- Setting a notes standard for a recurring meeting or a whole team.
- Preparing an agenda: the agenda items become the topic sections of the notes.
- Cleaning up inherited notes before they go into a wiki.

Not appropriate for verbatim minutes required by law or governance rules (board minutes, statutory meetings), which have their own format and approval process. For deep analysis of a transcript's risks and disagreements, use a dedicated meeting analysis agent; for task capture alone, use an action-item extraction skill.

## Inputs

- Raw material: notes, transcript, or recollection. Required.
- Meeting metadata: title, date, time zone, attendees, absentees, facilitator, note-taker.
- The agenda, if one existed.
- The team's existing template, if any — conform to it rather than replacing it.

## Procedure

1. **Write the header.** Title, date, attendees (with roles where helpful), absent, facilitator, note-taker, and links to the agenda, slides, or recording. Add a one-sentence purpose: why this meeting happened.
2. **Lead with outcomes.** Before any discussion, write three blocks in this order: Decisions, Action items, Open questions. Someone reading only these three blocks should know everything that changed.
3. **Record decisions precisely.** One sentence per decision in the past tense ("Agreed to ship v2 without offline mode"), plus who decided and any condition attached. If agreement was tentative, write "Tentative:" in front. Never promote a suggestion to a decision.
4. **Record action items in a fixed format.** `- [ ] <verb-first task> — @owner — due <date> — done when <criterion>`. One owner per item. If no owner or date was agreed, write "owner: unassigned" or "due: not set" so the gap is visible.
5. **List open questions** with who will answer and by when, if known.
6. **Write topic notes** under one heading per agenda item or topic. Use short bullets capturing key points, options considered, data cited, and dissent. Attribute statements only when attribution matters ("Finance noted the budget is fixed"). Leave out small talk, repetition, and process chatter.
7. **Mark parking-lot items** — topics raised but deferred — in their own short list.
8. **Normalise style.** Absolute dates (not "next Tuesday"), consistent names, expanded acronyms on first use, and links rather than pasted content.
9. **Validate.** Check that every action and decision in the topic notes also appears in the outcome blocks, every action has an owner field, and nothing in the outcomes is absent from the source material.

## Expected output

```markdown
# <Meeting title> — <YYYY-MM-DD>

**Purpose:** <one sentence>
**Attendees:** <names> · **Absent:** <names> · **Facilitator:** <name> · **Notes:** <name>
**Links:** <agenda / deck / recording>

## Decisions
- <Decision> — decided by <name/group> <condition if any>

## Action items
- [ ] <Task> — @<owner> — due <date> — done when <criterion>

## Open questions
- <Question> — to answer: <name> by <date>

## Notes
### 1. <Topic>
- <key point>
- Options considered: <...>
- Concern: <...>

## Parking lot
- <Deferred topic>
```

## Constraints and limitations

- Do not invent decisions, owners, or dates; mark gaps explicitly.
- Keep notes neutral: record positions, not judgements about people.
- Sensitive topics (personnel, legal, health) should be summarised at the level the audience is entitled to see; ask if unsure.
- Notes reflect what was said, not whether it is true; flag factual claims that need checking.
- If the team has a mandated format, follow it and only map these sections onto it.

## Examples

Raw notes: "talked pricing again. Sam thinks we should hold at 49. Lee wants 59 for new customers. agreed new customers 59 from March 1, existing stay 49. Lee to update the pricing page. need legal check on the terms change??"

Structured:

```markdown
## Decisions
- New-customer price set to 59 from 2026-03-01; existing customers stay at 49 — agreed by Sam and Lee

## Action items
- [ ] Update pricing page with new-customer price — @Lee — due: not set — done when live page shows 59 for new sign-ups

## Open questions
- Does the pricing change require updated terms? — to answer: Legal (unassigned)

## Notes
### 1. Pricing
- Sam favoured holding at 49; Lee proposed 59 for new customers
```
