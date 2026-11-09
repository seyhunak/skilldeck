---
name: llm-judge-rubric-design
description: Design LLM-as-judge evaluators - decomposed criteria with anchored scales, pointwise versus pairwise format, judge prompt structure, calibration against human labels, and controls for position, verbosity, and self-preference bias. Use when automating quality scoring of model outputs or when an existing judge's scores are not trusted.
---

# LLM Judge Rubric Design

## When to use
- Replacing or scaling human review of open-ended outputs (summaries, answers, agent results).
- An existing judge gives scores that disagree with what reviewers see.
- Choosing between absolute scoring and A/B comparison for a model or prompt change.

Not for: checking factual support against sources claim by claim (use `hallucination-detection`), or tasks with an exact reference answer, where programmatic checks are cheaper and more reliable than a judge.

## Inputs
- The task definition and what "good" means to the people who own the feature.
- 50-200 sample outputs, ideally with variation in quality.
- A subset (at least 50 items) labeled by humans using the draft rubric, for calibration.
- The judge model available to you, and whether it is the same model family that produced the outputs.

## Procedure
1. **Decompose quality into criteria.** Write 3-6 independent criteria (for example correctness, completeness, instruction adherence, tone) rather than one "overall quality" score. Each criterion must be observable in the output and the inputs given to the judge.
2. **Prefer the narrowest scale that works.** Binary pass/fail per criterion is the most reliable; use a 3- or 4-point scale only when intermediate levels drive different decisions. Anchor every level with a concrete description and, where possible, a short example. Avoid unanchored 1-10 scales.
3. **Pick pointwise or pairwise.**
   - Pointwise (score one output against the rubric): good for monitoring absolute quality and thresholds.
   - Pairwise (which of A or B is better on criterion X): more sensitive to small differences between two systems; use it for comparisons and A/B decisions.
   - Reference-guided: give the judge a reference answer when one exists; it improves correctness judgments.
4. **Write the judge prompt.** Include the task input, the output(s), any reference or sources, the rubric with anchors, and an instruction to write brief reasoning before the verdict. Request structured output, for example `{"criterion": ..., "reasoning": ..., "verdict": ...}`. One criterion per call is more reliable than many in one call, at higher cost.
5. **Control known biases.**
   - Position bias in pairwise: run both orders (A,B) and (B,A); count a win only if consistent, otherwise record a tie.
   - Verbosity bias: state in the rubric that length is not a merit; check correlation between score and output length.
   - Self-preference: where possible use a judge from a different model family than the system under test, or verify on the human-labeled set that it does not favour its own outputs.
6. **Calibrate against humans.** Run the judge on the human-labeled subset. Report raw agreement and a chance-corrected statistic (Cohen's kappa for two raters, or compare judge-human agreement with human-human agreement). A judge agreeing with humans about as often as humans agree with each other is usually adequate; set the bar before looking.
7. **Analyze disagreements.** Read every judge-human disagreement. Fix ambiguous anchors, add examples, or split criteria. Re-run calibration on a fresh subset to avoid tuning to the same items.
8. **Freeze and version.** Pin judge model version, prompt, rubric, and temperature (use 0 or the lowest supported). Re-calibrate when any of them change.

## Expected output
```markdown
## Judge spec: <feature> v<n>
Format: <pointwise | pairwise | reference-guided>; judge model: <name/version>; temperature: <x>
| Criterion | Scale | Anchors |
|---|---|---|
| Correctness | pass/fail | Pass: every factual statement matches the reference... |

Calibration (n=<n> human-labeled): agreement <x>%, kappa <k>; human-human kappa <h>
Bias checks: order consistency <x>%, score-length correlation <r>
Known weak spots: ...
Approved uses: <regression gating | monitoring | not for launch decisions>
```

## Constraints and limitations
- A judge is a measurement instrument with error; never use uncalibrated scores for launch decisions.
- Judges are weak at verifying facts they cannot see; give them the sources or a reference.
- Rubric changes invalidate historical comparisons; keep old scores labeled by rubric version.
- Do not let the judge see which system produced an output.

## Examples
A support-reply judge rated 90% of replies "4/5 helpful". Splitting it into binary criteria (resolves the issue, cites correct policy, asks for missing info when needed) and calibrating on 80 human-labeled replies exposed that "cites correct policy" failed on 22% of replies, a problem the single score had averaged away.
