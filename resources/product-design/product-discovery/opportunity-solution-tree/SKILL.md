---
name: opportunity-solution-tree
description: Build and use an opportunity solution tree (as described by Teresa Torres) that links one measurable product outcome to customer opportunities from research, several candidate solutions per target opportunity, and assumption tests for each solution. Use when a team needs to move from a goal to what to explore next without jumping to a single favourite feature, or to make discovery reasoning visible to stakeholders.
---

# Opportunity Solution Tree

The opportunity solution tree (OST), popularized by Teresa Torres in continuous discovery practice, is a visual structure with four levels: a desired **outcome** at the root, **opportunities** (customer needs, pain points, and desires discovered through research) beneath it, **solutions** that address a chosen opportunity, and **assumption tests** that evaluate those solutions. It keeps teams honest about why they are building something and makes it natural to compare options instead of committing to the first idea.

## When to use

- A team has been given an outcome (for example "increase weekly active teams") and needs to decide what to explore.
- Stakeholders bring feature requests and the team needs to place them in context.
- Discovery work feels scattered and needs a shared map.
- Choosing which opportunity to target next quarter.

Not for: delivery planning or effort estimation, ranking a backlog of already-defined features (use a scoring method such as `rice-prioritization`), or when no customer research exists — then the first step is research, and the tree remains a hypothesis sketch.

## Inputs

- One outcome, ideally a product outcome the team can influence (a behavior metric), with current value if known. Required.
- Research evidence: interview snapshots, synthesis, support data, analytics. Required for opportunities to be credible.
- Existing ideas or requests the team is considering. Optional.

## Procedure

1. **Set the outcome.** Choose one product outcome the team can directly influence, phrased as a metric with direction ("increase the share of new workspaces that create a second project within 14 days"). Push business outcomes (revenue) down to product outcomes (behavior that drives revenue). One tree per outcome.
2. **Collect opportunities from research.** Write opportunities as customer needs, pain points, or desires in the customer's words, not as solutions: "I don't know which template fits my project", not "add template recommendations". Each opportunity should cite its research source. Use JTBD outcomes from `jobs-to-be-done-analysis` if available.
3. **Structure the opportunity space.** Group opportunities into parent and child nodes: broad needs at the top, more specific ones beneath. A useful framing is to map them to stages of the customer's experience. Children should be distinct and, ideally, each solvable on its own. Re-check that every opportunity plausibly drives the outcome.
4. **Assess and choose a target opportunity.** Compare sibling opportunities by: how many customers are affected and how often (sizing), how much it matters to them, market factors (competitive gap or table stakes), and company factors (strategic fit, team strength). Pick the target among siblings rather than across the whole tree; specific child opportunities are easier to solve. Record why.
5. **Generate multiple solutions.** For the target opportunity, generate at least three distinctly different solutions. Diverge before converging; include a low-tech or non-software option. Avoid committing to the first idea.
6. **Identify assumptions for each solution.** Using story mapping or a walk-through of how the solution would work, list assumptions across desirability, viability, feasibility, usability, and ethics. Mark the riskiest.
7. **Design small assumption tests.** For the riskiest assumptions across the competing solutions, design quick tests (prototype tests, one-question surveys, data mining, small simulations) with a pre-stated success criterion. Compare solutions by test results, not by enthusiasm.
8. **Iterate the tree.** Update weekly as interviews add opportunities and tests retire solutions. Keep a dated change log so the reasoning stays visible.

## Expected output

```markdown
## Opportunity Solution Tree — <outcome> (baseline: <value>, <date>)

Outcome: <metric with direction>
├── Opportunity: <need in customer words> [evidence: P3, P8, tickets]
│   ├── Opportunity: <child need> [evidence ...]  <- TARGET (why: ...)
│   │   ├── Solution A: ...
│   │   │   └── Test: <assumption> — <method> — success if <criterion>
│   │   ├── Solution B: ...
│   │   │   └── Test: ...
│   │   └── Solution C: ...
│   │       └── Test: ...
│   └── Opportunity: ...
└── Opportunity: ...

### Target opportunity rationale
| Opportunity | Sizing | Customer importance | Market | Company fit | Decision |

### Change log
- <date>: ...
```

A Mermaid flowchart (`graph TD`) rendering is fine where supported.

## Constraints and limitations

- Opportunities must come from evidence; unevidenced ones are marked hypothesis.
- Never phrase opportunities as solutions; rewrite them.
- One outcome per tree. Several outcomes mean several trees.
- The tree guides discovery; it does not replace a roadmap or delivery plan.

## Examples

Outcome: increase the share of trial users who connect a data source in their first 3 days (baseline 31%).
Opportunities from 11 interviews: "I'm not sure my data is clean enough to connect" (P2, P5, P9); "I need IT approval to connect our warehouse" (P1, P4, P7, P10); "I want to see what the dashboards look like before connecting anything" (P3, P6).
Target: the IT-approval child opportunity — affects 4 of 11, blocks activation entirely, and competitors handle it poorly.
Solutions: A) a shareable security summary for IT; B) a read-only sample connection using a demo warehouse; C) an "invite your IT admin" flow with a pre-filled request.
Riskiest assumption for A: IT admins accept a vendor summary instead of a full questionnaire. Test: send the summary draft to 5 IT contacts from recent deals; success if 3 say it would be enough to approve a trial.
