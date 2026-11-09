# Product Discovery Sprint Routine

## Objective

Run a two-week discovery cycle in which a product trio (product manager, designer, engineering lead) moves from a target outcome to a documented decision — build, iterate, pivot, or stop — backed by customer evidence. Each cycle produces an updated opportunity solution tree, an assumption map with test results, a short evidence summary, and a decision record. The routine is designed to be repeated, so discovery becomes a steady habit rather than a one-off project.

## Trigger

Start a cycle when a team is assigned a new outcome, when a roadmap item in "Next" needs validation before commitment, when metrics show an unexplained problem, or simply on a fixed fortnightly cadence for teams practising continuous discovery. This is guidance for people to follow, optionally with an AI assistant drafting artifacts; it does not run on its own.

## Prerequisites

- A named trio with protected time (a useful heuristic is at least 20% of each member's time during the cycle).
- A target outcome agreed with the team's leader, expressed as a metric with direction.
- Access to customers: a recruiting channel (in-product intercept, customer success introductions, panel) and approval for incentives if used.
- Consent and recording process approved by whoever owns research ethics and privacy in your organization.
- A shared workspace for the tree, notes, and decision log.

## Inputs

- Target outcome and current baseline.
- Existing research, analytics, support themes, and prior discovery decisions.
- Candidate ideas and stakeholder requests already on the table.
- Constraints: deadline pressure, technical limits, legal or brand rules for experiments.

## Steps

1. **Day 1 — Frame (2 hours).** Confirm the outcome and baseline. Review existing evidence and prior decisions. Draft or update the opportunity solution tree (see the `opportunity-solution-tree` skill) and write the cycle's learning goal as a question: "Which opportunity, if addressed, most plausibly moves the outcome, and does solution X address it?"
2. **Day 1-2 — Recruit.** Book five to eight interviews for days 3-7 with participants who match the behavior of interest, not just the demographic. Prepare the interview guide with `user-interview-script-prompt`; keep questions about specific past behavior.
3. **Day 2 — Map assumptions.** For the current leading solution ideas, list assumptions across desirability, viability, feasibility, usability, and ethics; rank by importance and evidence. `product-discovery-agent` can draft the map for the trio to edit. Choose the two or three riskiest.
4. **Day 2-3 — Design tests.** For each risky assumption choose the cheapest credible test (data analysis, interview probe, prototype test, one-question survey, fake door with honest disclosure, concierge trial). Write the hypothesis, metric, sample, and pass threshold before running anything. Obtain approvals for any test touching live users, prices, or public pages.
5. **Days 3-7 — Interview and test.** Run interviews with at least two trio members present (one leads, one notes). Write an interview snapshot within 24 hours of each session: participant code, key story, opportunities heard, quotes, surprises. Run the assumption tests in parallel.
6. **Day 8 — Synthesize.** Cluster snapshot notes into opportunities (use `ux-research-synthesis-agent` for larger sets), update the tree with new opportunities and evidence counts, and record test results against their pre-committed thresholds without moving the goalposts.
7. **Day 9 — Decide.** Hold a decision review of 60 minutes with the trio and the outcome owner. For each solution under test choose: proceed to build (with what scope), iterate and re-test, pivot to a different opportunity or solution, or stop. Write a decision record: evidence, decision, confidence, what would change the decision, and next cycle's learning goal.
8. **Day 10 — Share and hand off.** Share a one-page summary with stakeholders, including what was dropped and why. If proceeding, hand off to delivery with the evidence, open questions, and the success metric; consider `prd-generation-agent` or `feature-spec-prompt` for the write-up. Book the next cycle's first interviews.

## Decision points

- **Outcome unclear on Day 1:** pause and agree it with the leader; a cycle without an outcome produces scattered research.
- **Fewer than four interviews booked by Day 3:** add recruiting channels or shift to tests on existing data; do not reduce rigor by interviewing people outside the profile.
- **Test result inconclusive:** check sample, wording, and segment mix; re-run a sharper test next cycle rather than declaring success.
- **Evidence contradicts a leadership-requested solution:** present the evidence in the decision review and escalate the choice to the outcome owner with options; do not suppress it.
- **Strong evidence early (by Day 6):** it is acceptable to end the cycle early and start delivery planning.

## Expected output

- Updated opportunity solution tree with evidence counts and the target opportunity marked.
- Interview snapshots for every session (anonymized).
- Assumption map with test designs, thresholds, and results.
- Decision record covering evidence, decision, confidence, and next learning goal.
- One-page stakeholder summary.

## Validation checklist

- [ ] The outcome and baseline were written down before research began.
- [ ] Pass thresholds for every test were recorded before results came in.
- [ ] At least five interviews about specific past behavior were completed, or the shortfall is explained.
- [ ] Every interview snapshot uses participant codes and contains no unnecessary personal data.
- [ ] Each tree opportunity cites its evidence source.
- [ ] The decision record states what was dropped as well as what proceeds.
- [ ] Any experiment involving live users, prices, or public pages had recorded approval.

## Human approval

The outcome owner must approve the target outcome on Day 1 and the decision on Day 9; the routine does not authorize build commitments on its own. Any experiment that exposes real customers to unreleased offers, prices, or public pages, or that offers incentives, needs explicit approval from the product leader and, where relevant, legal or privacy owners. Contacting customers, sending surveys, and publishing pages are always performed by people, not by an assistant acting alone.
