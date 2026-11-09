---
name: statistical-significance-testing
description: Selects and interprets the right significance test and confidence interval for a comparison - proportions, means, counts, ratios, paired or independent data - including assumption checks, effect sizes, power and sample size, multiple comparisons, and sequential peeking. Use when deciding whether an observed difference is distinguishable from noise or when reviewing someone else's statistical claim.
---

# Statistical Significance Testing

A p-value answers a narrow question: how surprising would data at least this extreme be if there were no true difference? It does not give the probability the hypothesis is true or the size of the effect. This skill helps choose a test that matches the data, report intervals and effect sizes alongside p-values, and phrase conclusions without overclaiming.

## When to use

- Comparing two or more groups on a metric (variants, segments, periods) and judging whether the difference is real.
- Planning sample size or checking whether a study was powered for the effect of interest.
- Reviewing a claim like "significant at p < 0.05" in a report.
- Not for causal claims from observational data; significance does not remove confounding.

## Inputs

- The metric type and its unit of analysis (per user, per session, per order).
- Group sizes and summary statistics (counts, means, variances) or raw values.
- Study design: independent groups or paired/repeated measures; randomized or observational.
- Pre-specified hypothesis, significance level (alpha), and minimum effect of interest, if any.
- How many comparisons were made and whether results were checked repeatedly.

## Procedure

1. **Frame the hypotheses and alpha.** State the null and alternative, one- or two-sided (default two-sided unless a one-sided question was pre-registered), and alpha (commonly 0.05; a convention, not a law). State the smallest effect that would matter in practice.
2. **Match the test to the data.**
   - Two proportions (conversion): two-proportion z-test or chi-square test; Fisher's exact test when expected cell counts are small (a common rule of thumb is below 5).
   - Two means, independent: Welch's t-test (does not assume equal variances); with large samples the central limit theorem makes it robust to non-normality, but heavy tails (revenue) still inflate variance - consider winsorizing, a log transform with care about interpretation, or a bootstrap interval.
   - Paired measurements (same units before/after): paired t-test, or Wilcoxon signed-rank for non-normal small samples.
   - More than two groups: chi-square for proportions, ANOVA or Kruskal-Wallis for means/ranks, followed by corrected pairwise comparisons.
   - Counts per unit time: Poisson or negative binomial (if overdispersed) rate comparison.
   - Ratio metrics where the denominator is not the randomization unit (clicks per session randomized by user): delta method or bootstrap at the randomization unit.
   - Medians or percentiles: bootstrap confidence intervals; quantile-specific methods.
3. **Check assumptions.** Independence of observations (repeated events from one user are not independent), adequate sample size, no severe imbalance or outliers dominating, randomization or comparable groups.
4. **Compute the interval and effect size.** Report the difference with a confidence interval (absolute and relative), and the p-value. For proportions, the Wald interval for a difference is `(p1 − p2) ± z · sqrt(p1(1−p1)/n1 + p2(1−p2)/n2)`; prefer Wilson or Newcombe intervals for small samples or rates near 0 or 1. Standardized effect sizes (Cohen's d, odds ratio) help when units are not intuitive.
5. **Check power when the result is not significant.** For two proportions, a standard approximation of sample size per group is `n ≈ (z_{1−α/2} + z_{1−β})² · [p1(1−p1) + p2(1−p2)] / (p1 − p2)²`. If the study could only detect effects much larger than the minimum effect of interest, the result is inconclusive, not evidence of no effect.
6. **Correct for multiplicity.** With many metrics, segments, or variants, control the error rate: Bonferroni (simple, conservative), Holm (uniformly more powerful than Bonferroni for family-wise error), or Benjamini-Hochberg (controls false discovery rate, suited to exploratory screens). State which family of tests was corrected.
7. **Handle peeking.** Repeatedly checking a fixed-horizon test and stopping when p < alpha inflates false positives substantially. Either analyze only at the planned horizon, or use a sequential design (group sequential with alpha spending, or always-valid/mSPRT methods) chosen in advance.
8. **Write the conclusion carefully.** Report effect, interval, p-value, and practical significance together. Use phrasing such as "the data are consistent with a lift between +0.2 and +1.4 percentage points", not "there is a 95% chance the true lift is in this range" (that is a Bayesian credible interval statement) and never "p > 0.05 proves no difference".

## Expected output

```markdown
**Question:** … · **Design:** independent / paired, randomized / observational
**Test:** … · **Why:** … · **Assumptions checked:** …
**Result:** difference … (95% CI … to …), relative …, p = …
**Practical significance:** vs minimum effect of interest …
**Power / MDE:** …
**Multiplicity / sequential adjustments:** …
**Conclusion:** <one careful sentence> · **Caveats:** …
```

## Constraints and limitations

- Statistics cannot rescue a biased design or bad data; check data validity first.
- Thresholds such as alpha = 0.05 and rule-of-thumb sample sizes are conventions; report exact values.
- Bayesian approaches are a legitimate alternative; if used, report priors and posterior intervals rather than mixing vocabularies.
- When raw data are unavailable, say which calculations are approximations from summaries.

## Examples

Control: 4,800 conversions of 120,000 users (4.00%). Treatment: 5,040 of 120,000 (4.20%). Difference +0.20 pp; standard error = sqrt(0.04·0.96/120000 + 0.042·0.958/120000) ≈ 0.00081; 95% CI ≈ +0.04 to +0.36 pp; z ≈ 2.46, p ≈ 0.014. Relative lift +5.0%. Conclusion: statistically distinguishable from zero at alpha = 0.05; if the minimum worthwhile lift was +0.3 pp, the interval includes values below it, so the practical case is uncertain.
