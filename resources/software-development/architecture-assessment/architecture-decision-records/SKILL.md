---
name: architecture-decision-records
description: Writes Architecture Decision Records in MADR or Nygard format - context and decision drivers, genuinely considered options with pros and cons, the decision, consequences, and status lifecycle (proposed, accepted, deprecated, superseded). Use when a team makes or has made a significant, hard-to-reverse technical choice that future engineers will need to understand.
---

# Architecture Decision Records

An ADR captures one architecturally significant decision: why it was needed, what alternatives were weighed, what was chosen, and what that commits the team to. The value is in the reasoning, which is exactly what gets lost when people leave. This skill writes ADRs that are short, honest about trade-offs, and maintained over time.

## When to use

- A decision affects structure, quality attributes, dependencies, interfaces, or build and deploy approach, and is costly to reverse (choice of database, messaging pattern, auth model, monolith vs services split, framework adoption).
- Recording a decision already made (retroactive ADR) so the reasoning is not lost.
- Superseding or deprecating an earlier decision.
- Setting up an ADR practice in a repository.

Not for: full design documents with detailed implementation plans (`technical-design-doc-prompt`), or evaluating an existing architecture against quality attributes (`architecture-review-agent`). Trivial, easily reversed choices do not need an ADR.

## Inputs

- The problem and the forces: requirements, constraints (team skills, budget, deadlines, compliance), quality attributes at stake (latency, availability, cost, operability).
- Options under consideration, including "do nothing" where realistic.
- Evidence: spikes, benchmarks, vendor docs, incident history. Mark anything unverified.
- Existing ADRs (often `docs/adr/` or `docs/decisions/`) to number and link correctly.

## Procedure

1. **Confirm it is one decision.** An ADR answers a single question ("How do services publish domain events?"). If the request bundles several, split them and link the ADRs.

2. **Pick the template the repo already uses.** Default to MADR (Markdown Architectural Decision Records) for its explicit options section; the shorter Nygard form (Title, Status, Context, Decision, Consequences) suits small decisions. Number sequentially with a zero-padded prefix and a kebab-case title: `0007-use-postgres-outbox-for-domain-events.md`.

3. **Write context neutrally.** Describe the situation and the forces in tension without arguing for the answer. Include facts and numbers with sources (current load, SLOs, team size). A reader should be able to imagine choosing a different option from the context alone.

4. **List decision drivers.** The criteria that matter, in priority order: e.g. "at-least-once delivery without two-phase commit", "operable by a team of four", "no new managed service this year".

5. **Present real options.** Two to four options that were seriously considered. For each: a one-line description, then pros and cons tied to the drivers ("Good, because...", "Bad, because..."). Avoid straw men; if an option was rejected quickly, say why in one line. A comparison table against drivers helps when there are several.

6. **State the decision and its justification.** "Chosen option: X, because..." referencing drivers. Include scope ("applies to new services; existing services migrate when touched") and any conditions that would trigger revisiting it.

7. **Spell out consequences — both directions.** Positive, negative, and neutral: new operational work, skills needed, costs, constraints imposed on future decisions, follow-up tasks. Negative consequences are not a weakness of the ADR; omitting them is.

8. **Set status and metadata.** Status lifecycle: Proposed → Accepted (or Rejected) → later Deprecated or Superseded by ADR-NNNN. Record date and deciders. Accepted ADRs are not rewritten; to change course, write a new ADR and update the old one's status line to "Superseded by 0012" with a link.

9. **Add confirmation.** How compliance will be checked: an architecture fitness function, a lint rule, a review checklist item, or a dependency rule (ArchUnit, dependency-cruiser, import-linter).

## Expected output

```markdown
# 0007. Use a transactional outbox for domain events

- Status: Proposed
- Date: 2026-11-09
- Deciders: <names or roles>

## Context and problem statement
## Decision drivers
## Considered options
1. Transactional outbox table polled by a relay
2. Publish to the broker inside the request after commit
3. Change data capture from the database log
## Decision outcome
Chosen option: "1", because ...
### Consequences
- Good, because ...
- Bad, because ...
### Confirmation
## Pros and cons of the options
## More information
<links to spikes, related ADRs, revisit triggers>
```

## Constraints and limitations

- Do not invent benchmarks, costs, or vendor capabilities; cite sources or mark as assumptions to verify.
- An ADR drafted by an assistant is a proposal; set status to Proposed until the deciders accept it.
- Keep it to about one or two pages; link out to detailed analysis.
- Do not edit accepted ADRs' substance retroactively; supersede them.

## Examples

**Request:** "We chose Kafka over RabbitMQ last year; nobody remembers why. Write it up."
**Approach:** retroactive ADR, status Accepted with the original decision date if known (otherwise "date unknown, recorded 2026-11-09"). Context reconstructed from the user's account and repo evidence (e.g. replay requirements in a design doc), with each reconstructed claim marked as such. Options: Kafka, RabbitMQ, managed cloud queue. Consequences include the operational cost of running Kafka that the team now carries, and a revisit trigger if replay is no longer needed.
