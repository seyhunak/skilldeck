# Business Model Canvas

## Intended task
Draft and critique a Business Model Canvas (Osterwalder and Pigneur's nine building blocks) for a new venture, a new product line, or an existing business being rethought. The prompt goes beyond filling boxes: it keeps the canvas focused on one primary customer segment, labels each entry as evidence or assumption, checks fit between blocks, tests whether the revenue model can plausibly cover the cost structure, and finishes with the riskiest assumptions and cheap tests to validate them. Use it at idea stage, before a business case, or when comparing alternative business models for the same offering.

## Required context
- **Business description** — what is offered, to whom, and how it makes money (even tentatively).
- **Known evidence** — customer interviews, pilot results, sales data, cost quotes.
- **Stage** — idea, early traction, or established; this changes how much should be marked as assumption.
- **Alternatives** — optional other model variants (for example subscription vs. transaction fees) to compare.

## Prompt
```text
You are a business model strategist. Build and critique a Business Model Canvas for the following business.

Business description:
{{BUSINESS_DESCRIPTION}}

Stage: {{STAGE}}

Evidence available (interviews, data, pilots, quotes):
{{EVIDENCE}}

Model variant to compare (may be empty): {{ALTERNATIVE_MODEL}}

Instructions:
1. Identify the primary customer segment. If several segments are described, pick the one the business depends on most and list the others separately; a canvas that serves everyone is not useful. For multi-sided platforms, list each side as its own segment and show which side subsidises which.
2. Fill all nine blocks for that segment: Customer Segments, Value Propositions, Channels, Customer Relationships, Revenue Streams, Key Resources, Key Activities, Key Partnerships, Cost Structure. Be specific to this business; avoid generic entries such as "high quality" or "social media".
3. Tag every entry [E] if supported by the supplied evidence or [A] if it is an assumption. Never invent market sizes, prices, or customer quotes.
4. For Revenue Streams state the pricing mechanism (subscription, usage, transaction fee, licence, advertising, and so on) and, where numbers are given, a rough revenue per customer. For Cost Structure separate fixed and variable costs and say whether the model is cost-driven or value-driven.
5. Check fit: does each value proposition address a stated job or pain of the segment? Does each channel reach that segment? Does each key activity and resource support the value proposition? List any block entries that do not connect to anything.
6. Check viability: using only supplied numbers or clearly labelled assumptions, assess whether revenue per customer, after variable costs, can plausibly cover acquisition costs and fixed costs at a reachable scale. State the break-even logic or the data needed for it.
7. Rank the five riskiest assumptions by (impact if wrong) x (lack of evidence). For each, propose a cheap test with a success threshold and a timeframe of under four weeks where possible.
8. If an alternative model is provided, show which blocks change and how the risk profile differs.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{BUSINESS_DESCRIPTION}}` | What the business offers, to whom, and how it earns money | Yes |
| `{{STAGE}}` | idea / early traction / established | Yes |
| `{{EVIDENCE}}` | Interview notes, metrics, pilot results, cost data | No |
| `{{ALTERNATIVE_MODEL}}` | A different model variant to compare | No |

## Output format
```markdown
## Business Model Canvas: <business> — primary segment: <segment>
| Block | Entries ([E]/[A]) |
|---|---|
| Customer Segments | |
| Value Propositions | |
| Channels | |
| Customer Relationships | |
| Revenue Streams | |
| Key Resources | |
| Key Activities | |
| Key Partnerships | |
| Cost Structure | |

### Fit check
### Viability check
### Riskiest assumptions and tests
| # | Assumption | Block | Why risky | Test | Success threshold | Timeframe |
### Alternative model comparison (if requested)
### Other segments to canvas separately
```

## Example usage
For "a service that rents professional-grade power tools to homeowners via lockers at hardware stores, charging per day", stage "idea", with evidence from 12 homeowner interviews, a good response picks "DIY homeowners doing occasional projects" as the primary segment, tags locker partnerships with hardware stores as [A], and finds a fit gap: the value proposition stresses "no need to own tools" but the channel requires two store visits per rental. The viability check notes that tool depreciation and damage rates are unknown and are decisive for unit economics. The riskiest assumption is retailer willingness to host lockers; the test is five retailer conversations with a letter-of-intent threshold of two.

## Customization
- For established businesses, ask for a current-state canvas and a future-state canvas, then list the changes.
- Swap in the Lean Canvas blocks (problem, solution, key metrics, unfair advantage) for very early startups.
- Add a "sustainability" row for environmental and social costs and benefits if the business needs it.
- Keep the [E]/[A] tagging; it is the main defence against a confident but unfounded canvas.
