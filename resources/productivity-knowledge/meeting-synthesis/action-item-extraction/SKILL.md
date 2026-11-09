---
name: action-item-extraction
description: Extracts commitments from meetings, emails, chats, or documents into well-formed action items - verb-first task, single accountable owner, due date as stated, definition of done, and source reference - and flags vague or orphaned commitments. Use whenever text contains promises or requests that need to become trackable tasks.
---

# Action Item Extraction

Most dropped work is not forgotten; it was never captured precisely. "We should look into the latency thing" contains no owner, no deadline, and no finish line. This skill finds every commitment in a piece of text and turns it into an item a task tracker can hold and a manager can follow up on, while making the gaps visible instead of papering over them.

## When to use

- After a meeting, from notes or a transcript.
- On an email or chat thread where people agreed to do things.
- On a document (project plan, review comments, audit findings) that implies tasks.
- Before importing tasks into a tracker such as Jira, Linear, Asana, or a plain to-do list.

Not appropriate for prioritising or scheduling the tasks (that is a planning job), or for deciding who should own unowned work — the skill flags it, a human assigns it.

## Inputs

- The source text. Required.
- The date of the source, so relative dates ("by Friday") can be resolved. If missing, keep the relative phrase and flag it.
- Participant names and roles, to resolve "I", "you", and nicknames.
- Optional: the target tracker's fields, to shape the output.

## Procedure

1. **Scan for commitment signals.** First person futures ("I'll send", "I can take that"), direct requests that were accepted ("Can you…?" "Sure"), assignments ("Maria owns the rollout"), group intentions ("we need to", "someone should"), and conditional promises ("if legal agrees, I'll…"). Requests that were declined or left unanswered are not commitments; list them separately as unconfirmed.
2. **Rewrite each as a verb-first task.** Start with a concrete verb (send, draft, decide, fix, book, review) and name the object: "Send revised quote to Acme" not "Acme quote". Split compound items: "update the doc and tell the team" is two actions.
3. **Assign exactly one owner** — the person who said they would do it or who was asked and accepted. If the speaker is "we", "the team", or "someone", record owner as unassigned. If several people are involved, name one accountable owner and list others as contributors only if the source says so.
4. **Capture the due date as stated.** Convert relative dates to absolute dates using the source date and say so ("Friday → 2026-11-13"). If no date was given, write "not set"; never infer a deadline from urgency of tone.
5. **Write a definition of done.** One short observable criterion: "quote emailed to buyer", "PR merged to main", "decision recorded in log". If the source does not imply one, propose it and mark it as proposed.
6. **Record dependencies and conditions.** "Blocked by: legal sign-off" or "Only if budget approved". Conditional commitments stay conditional.
7. **Cite the source** with a timestamp, message date, or quoted phrase, so the owner can see exactly what they agreed to.
8. **Flag quality problems** in a separate list: unassigned owners, missing dates, vague verbs ("look into", "think about", "handle"), duplicates of the same commitment, and items that conflict with each other.
9. **Validate.** Re-read the source once more for missed commitments, especially near the end of meetings and in parenthetical remarks, and confirm no item was invented.

## Expected output

```markdown
## Action items
| # | Action | Owner | Due | Definition of done | Depends on | Source |
|---|---|---|---|---|---|---|
| 1 | Send revised quote to Acme | Dana | 2026-11-13 (from "Friday") | Quote emailed to Acme buyer | Pricing approval (#3) | 14:32 "I'll get Acme the new quote by Friday" |

## Needs attention
- #4 owner unassigned ("someone should check the SSO bug")
- #5 vague verb: "look into latency" — suggest "Measure p95 latency on checkout and report findings"

## Unconfirmed requests
- Request to Ops for extra staging capacity — no response in thread
```

For tracker import, also provide one line per item: `<Action> | <Owner> | <Due> | <Done when>`.

## Constraints and limitations

- Never invent owners, dates, or commitments; uncertainty is shown, not resolved.
- Sarcasm, jokes, and hypotheticals ("I suppose I could rewrite the whole thing") are not commitments unless confirmed.
- Transcription errors in names are common; flag uncertain names rather than guessing.
- The skill extracts; it does not notify owners or create tickets unless the calling user explicitly asks and approves.

## Examples

Source (chat, 2026-11-10, Tuesday):
> Ana: can someone look at the flaky login test?
> Ben: I'll take it, should have a fix by Thursday
> Ana: great. also we need to tell support about the outage window
> Chris: if the change window is confirmed I'll post in #support

Extracted:

| # | Action | Owner | Due | Definition of done | Depends on | Source |
|---|---|---|---|---|---|---|
| 1 | Fix flaky login test | Ben | 2026-11-12 (from "Thursday") | Test passes reliably in CI (proposed) | — | Ben: "I'll take it…" |
| 2 | Post outage window notice in #support | Chris | not set | Message posted in #support | Change window confirmed | Chris: "if the change window…" |

Needs attention: #2 is conditional and undated; nobody owns confirming the change window.
