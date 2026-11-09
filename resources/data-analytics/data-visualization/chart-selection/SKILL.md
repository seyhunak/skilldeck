---
name: chart-selection
description: Chooses the chart form for an analytical question by identifying the comparison being made (change over time, ranking, part-to-whole, distribution, relationship, deviation, geography, flow) and the data shape, then specifies encoding, scale, ordering, color, and annotation rules. Use when designing a chart, dashboard tile, or slide, or when critiquing a chart that misleads.
---

# Chart Selection

Pick the chart from the question, not from the data or the tool's default. Position along a common scale is read most accurately, followed by length, then angle and area, then color intensity (the ranking popularized by Cleveland and McGill's perception studies). Choose forms that put the key comparison on position or length.

## When to use

- Designing a single chart, a dashboard tile, or a report figure.
- Reviewing an existing chart that feels confusing or seems to exaggerate.
- Translating a stakeholder request ("show me X") into a chart specification.
- Not for building the chart in a specific library; this skill produces the specification.

## Inputs

- The question the chart must answer, in one sentence.
- The data: measures, dimensions, cardinality of each dimension, time granularity, and number of series.
- Audience and medium: executive slide, operational dashboard, analyst notebook, mobile.
- Optional: brand or accessibility constraints.

## Procedure

1. **Name the comparison.** Classify the question:
   - *Change over time* - trend, seasonality, before/after.
   - *Ranking / comparison across categories* - which is biggest, how do they compare.
   - *Part-to-whole* - composition and share.
   - *Distribution* - spread, skew, outliers.
   - *Relationship* - correlation between two or more measures.
   - *Deviation* - variance from target, plan, or baseline.
   - *Geography* or *flow* - only when location or movement is the point.
2. **Map to candidate forms.**
   - Time: line chart (continuous, many points); column chart (few discrete periods, or counts per period); area only for a single series or when the total matters; small multiples when there are more than about 4-5 series.
   - Ranking: horizontal bar sorted by value (long labels fit); dot plot when bars would all be long and differences small; lollipop as a lighter bar.
   - Part-to-whole: stacked bar (100% stacked to compare shares across groups); pie or donut only for 2-3 parts with a single whole; treemap for hierarchical many-part data where precision is not required; waterfall for how components add up to a change.
   - Distribution: histogram (one variable), box or violin plots (compare groups), strip/beeswarm for small n, ECDF for precise percentile comparisons.
   - Relationship: scatter plot (add trend line with caution), bubble chart only if the third variable matters; heatmap for two categorical dimensions against a measure (also cohort tables).
   - Deviation: diverging bars around zero or target, bullet charts for actual vs. target, line with a target band.
   - Single KPI: big number with comparison (delta vs. prior and target) and a sparkline.
3. **Set the scale.** Bar and column charts start at zero, always, because length encodes value. Line charts may use a non-zero baseline if labeled, since slope carries the message. Use log scales for multiplicative growth or ranges spanning orders of magnitude, and label them clearly. Avoid dual y-axes; use two aligned charts or index both series to 100.
4. **Order and group.** Sort categorical bars by value unless the category has a natural order (age bands, funnel steps, weekdays). Group the long tail into "Other" beyond roughly 7-10 categories as a heuristic. Keep time on the horizontal axis, left to right.
5. **Use color with intent.** Default to a neutral color and highlight only what the reader should notice. Use sequential palettes for ordered magnitudes, diverging palettes for values around a meaningful midpoint, categorical palettes for at most about 6-8 distinguishable groups. Do not rely on red/green alone; ensure sufficient contrast and add direct labels or patterns.
6. **Annotate.** Title states the takeaway ("Conversion fell after the 14 Oct release"), not the variable list. Direct-label lines instead of using a legend when possible. Mark targets, events, incomplete periods (dashed or shaded), and data sources with as-of dates.
7. **Remove distortion and clutter.** No 3D, no gauges for precise comparison, no truncated bar axes, no unexplained smoothing, minimal gridlines, consistent units and decimal places.
8. **Check against the question.** Can the reader answer the one-sentence question within a few seconds? If not, simplify or split.

## Expected output

```markdown
**Question:** …
**Comparison type:** …
**Chart:** <chart type> · **Why:** <one sentence> · **Rejected alternatives:** <chart type - reason>
**Encoding:** x = …, y = …, color = …, facet = …
**Scale:** baseline …, linear/log, units …
**Order:** …
**Annotations:** title "<takeaway>", labels …, reference lines …
**Accessibility:** palette …, direct labels …
```

## Constraints and limitations

- Heuristic thresholds (category counts, series counts) are guidance, not rules; state when you depart from them and why.
- The best chart for exploration often differs from the best chart for presentation; ask which is needed.
- If the data cannot support the comparison (too few points, incomparable units), say so instead of choosing a chart.

## Examples

Question: "Which acquisition channels drove the most new paying customers last quarter, and how does that compare with the quarter before?" Comparison: ranking plus change. Chart: horizontal dot plot (dumbbell) with two points per channel for the two quarters, channels sorted by last quarter's value, gray for the prior quarter and one accent color for the latest. Rejected: grouped column chart (harder to read many labels), pie chart (cannot show change). Title: "Paid search overtook referrals as the top source of new customers in Q3."
