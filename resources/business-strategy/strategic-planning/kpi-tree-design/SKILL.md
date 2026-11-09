---
name: kpi-tree-design
description: Build a KPI driver tree that breaks a north-star or top-level metric (revenue, profit, active users, retention) into mathematically linked sub-metrics down to controllable levers, with definitions, owners, data sources, and leading/lagging labels. Use when choosing what to measure, linking team goals to company outcomes, setting targets, or diagnosing why a top-line metric moved.
---

# KPI Tree Design

A KPI tree (driver tree, metric tree) expresses a top-level metric as a combination of its drivers, level by level, until each leaf is something a team can act on. Unlike a list of KPIs, every parent equals a defined function of its children, so the tree can be used to model targets and to attribute changes.

## When to use

- Defining a north-star metric and the inputs teams will own.
- Connecting OKRs or team goals to company outcomes.
- Setting targets: working out what combination of driver improvements reaches a top-line goal.
- Diagnosing a change in a top metric by walking down the branches.
- Not for choosing chart types or dashboard layout; the tree defines what to measure, not how to display it.

## Inputs

- The business model and the top-level outcome the organisation cares most about.
- Current metric definitions and available data sources.
- Organisational structure (to map owners to branches).
- Optionally, current values for each metric to quantify sensitivity.

## Procedure

1. **Choose the root.** Pick one outcome metric that reflects value delivered and captured. For a product north star, prefer a metric that captures customer value and predicts revenue (for example weekly active teams completing a core action) over pure revenue. Define it precisely: formula, unit, time window, inclusions and exclusions.
2. **Decompose with explicit arithmetic.** At each level split the parent into children that combine by addition (segments: new + expansion + existing revenue), multiplication (funnels: visitors x conversion rate x average order value), or a ratio. Write the equation beside each split. Keep each split MECE — mutually exclusive and collectively exhaustive — so no part of the parent is missing or double counted.
3. **Choose the split that fits the business.** Revenue can be split by customer type, product, channel, or geography, or by volume x price. Choose the dimension along which teams and decisions are organised, or that best explains historical variance; you can add an alternative split as a separate view.
4. **Descend to levers.** Continue until leaves are input metrics a team can directly influence within weeks (for example trial-to-paid conversion, onboarding completion rate, sales cycle length, on-time delivery). Typically three to five levels; beyond that the tree becomes unreadable.
5. **Label each node.** Mark lagging outcome or leading input; controllable, influenceable, or external (for example market demand). External nodes should be tracked but not owned as targets.
6. **Add definitions, owners, and sources.** Each node gets a written definition, one owner team, the data source, refresh frequency, and current value where available. Nodes with no reliable source become measurement gaps.
7. **Quantify sensitivity.** Using current values, estimate how a realistic improvement in each leaf (for example plus 10%) changes the root. For multiplicative branches the effect propagates proportionally; for additive ones, by the leaf's share. Rank levers by impact and feasibility.
8. **Add guardrails.** For levers that can be gamed (speed, volume), add counter-metrics (quality, refunds, churn) beside the tree.
9. **Validate with history.** Check that the equations reproduce historical values of the root within an acceptable tolerance; large residuals indicate a missing driver or a definition mismatch.

## Expected output

```markdown
## KPI Tree: <root metric>
Root definition: ...

Root = A + B   (or A x B x C)
├── A: <metric> = A1 x A2         [lagging · owner · source]
│   ├── A1: <metric>              [leading · controllable · owner · source · current]
│   └── A2: <metric>              [...]
└── B: <metric> = ...

### Node dictionary
| Node | Definition | Formula | Type | Controllability | Owner | Source | Refresh | Current |

### Lever sensitivity
| Lever | +10% change | Effect on root | Feasibility | Priority |

### Guardrail metrics
### Measurement gaps
```

## Constraints and limitations

- Decompositions describe arithmetic, not causation; a lever moving does not guarantee the parent moves if other drivers shift.
- Cross-branch interactions (a price increase reducing conversion) are not captured by the tree alone and need explicit notes or modelling.
- Ratios at different levels can mislead when the mix shifts (Simpson's paradox); check segment-level trends.
- Using tree metrics for individual performance ratings invites gaming; involve HR if that is proposed.

## Examples

**Root:** monthly recurring revenue (MRR) for a B2B SaaS.
**Tree:** MRR = starting MRR + new MRR + expansion MRR - contraction MRR - churned MRR. New MRR = qualified leads x win rate x average new contract value. Qualified leads = website trials x trial-to-qualified rate + outbound meetings x qualification rate. Churned MRR = starting MRR x revenue churn rate, with churn split by onboarding-completed vs. not.
**Insight from sensitivity:** a 10% lift in win rate adds more MRR than a 10% lift in trials because the trial-to-qualified rate is low, so the sales enablement team owns the higher-priority lever this quarter.
