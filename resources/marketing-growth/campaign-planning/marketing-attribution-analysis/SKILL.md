---
name: marketing-attribution-analysis
description: Compares attribution models (last-click, first-touch, linear, time-decay, position-based, platform data-driven) on campaign and conversion-path data, explains where and why they disagree, triangulates with incrementality evidence, and states budget implications with honest caveats. Use when allocating budget across channels or reconciling conflicting channel credit.
---

# Marketing Attribution Analysis

A method for showing how conversion credit changes with the attribution model, why, and what that means for budget decisions. The central caveat runs throughout: attribution models allocate credit among observed touchpoints; they do not measure what would have happened without a channel.

## When to use

- Deciding how to split budget across channels and different reports disagree.
- Explaining why platform-reported conversions sum to more than actual conversions.
- Evaluating upper-funnel channels that look poor under last-click.
- Preparing to design an incrementality test.

Not a substitute for an incrementality experiment or a marketing mix model when large budget decisions depend on causal impact.

## Inputs

- **Conversion paths** — ordered touchpoints per converting customer (channel, campaign, timestamp) from analytics or a customer data platform, ideally with non-converting paths too. Required for rule-based models.
- **Conversions and value** — from the system of record (CRM or orders).
- **Spend by channel** for cost-per-acquisition comparisons.
- **Platform-reported conversions** per channel for reconciliation.
- **Incrementality evidence** — holdout tests, geo experiments, conversion lift studies, or a marketing mix model, if any.
- **Lookback window** and conversion definition.

## Procedure

1. **Check path data quality.** Measure the share of conversions with only a single touch, with "direct" or unknown as the only touch, and with missing identifiers. Consent choices, cross-device journeys, and view-through impressions not captured in analytics all truncate paths. State coverage before modelling; if most paths are single-touch, multi-touch models will barely differ from last-click.
2. **Compute rule-based models.** For each conversion, distribute credit:
   - Last-click: 100% to the final touch (often excluding direct if a prior touch exists, depending on the tool's convention; state which).
   - First-touch: 100% to the first touch.
   - Linear: equal shares across touches.
   - Time-decay: more credit to touches closer to conversion (commonly a 7-day half-life; state the parameter).
   - Position-based: 40% first, 40% last, 20% spread across middle touches (a common default; state it).
   Sum credit by channel and compute cost per attributed conversion and attributed ROAS under each model.
3. **Compare and explain.** Build a channel-by-model table. Channels gaining credit under first-touch and position-based models are introducers (often paid social, display, content); channels losing credit are closers (often branded search, retargeting, email). Explain each large shift with path evidence, for example the median position of the channel in paths.
4. **Reconcile with platform reports.** Compare the sum of platform-reported conversions with actual conversions. Over-counting arises because each platform claims conversions it touched, often including view-throughs and different windows. Express it as a ratio and do not add platform numbers together.
5. **Include data-driven attribution carefully.** If an analytics or ad platform's data-driven model is available, include it as another view, noting that its method is not fully transparent and that it remains correlational.
6. **Triangulate with incrementality.** Where holdout or lift tests exist, compute an incrementality factor (incremental conversions divided by attributed conversions) and apply it to the matching channel. Where none exist, label channels by risk of over-crediting: branded search and retargeting capture existing demand and are frequently over-credited; prospecting channels may be under-credited by last-click.
7. **State budget implications.** Recommend directional moves only where models agree, or where incrementality evidence supports them. Where models disagree, recommend a test (geo split, holdout, or budget on/off in matched markets) rather than a reallocation.
8. **Document assumptions.** Lookback window, model parameters, channel grouping, deduplication rules.

## Expected output

```markdown
# Attribution Analysis: <period>
**Paths analysed:** <n> · **Single-touch share:** <x%> · **Lookback:** <days> · **Conversion source:** <system>

| Channel | Spend | Last-click | First-touch | Linear | Time-decay | Position-based | Platform-reported | Incrementality evidence |

## Where models disagree and why
## Reconciliation with platform reports
## Budget implications (confidence: high/medium/low)
## Recommended tests
## Assumptions and data gaps
```

## Constraints and limitations

- All rule-based models are correlational; none answers "what if we stopped spending here?".
- Path data under-represents impressions, offline influence, word of mouth, and cross-device journeys.
- Model parameters are conventions, not facts; changing them changes the answer.
- Use aggregated or pseudonymised path data; never export identifiable user journeys into reports.

## Examples

A subscription app has 5,000 conversions. Under last-click, branded search receives 38% of credit and paid social 9%; under position-based, branded search falls to 24% and paid social rises to 21%. Path data shows paid social is the first touch in 30% of multi-touch paths. A geo holdout from last quarter showed retargeting incrementality of about 0.3 (30% of its attributed conversions were incremental). Recommendation: do not cut paid social on last-click evidence; reduce retargeting frequency caps; run a four-week geo holdout on paid social before shifting more than a small share of budget.
