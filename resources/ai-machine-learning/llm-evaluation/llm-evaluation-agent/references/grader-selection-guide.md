# Grader selection guide

Pick the cheapest grader that measures the criterion reliably. Escalate to a more expensive grader only when the cheaper one cannot express the criterion.

| Criterion type | Preferred grader | Notes |
|---|---|---|
| Output parses and matches a schema | Code: schema validator | Deterministic; report parse failure separately from content failure |
| Classification label or enum | Code: exact match, macro-F1 across classes | Report per-class results; accuracy hides minority-class failures |
| Extracted fields | Code: field-level exact or normalized match | Normalize dates, whitespace, case before comparing |
| Numeric answer | Code: tolerance match | State the tolerance and units |
| Generated code | Code: run tests in a user-provided sandbox | Never execute generated code outside an isolated environment |
| Must or must not mention X | Code: keyword or regex, then judge on misses | Regex has false negatives on paraphrase; audit a sample |
| Factual consistency with source | Model: claim extraction plus per-claim support check | Calibrate against humans; long sources raise judge error |
| Tone, style, policy adherence | Model: rubric with anchored examples | Binary pass/fail with explicit conditions is easier to calibrate than 1-10 scales |
| Which of two outputs is better | Model or human: pairwise, order randomized | Run both orders and count ties when the judge flips |
| Task success in a multi-step agent | Code on end state where possible, otherwise model on transcript | Check final environment state rather than the agent's own claim of success |
| High-stakes correctness (medical, legal, financial content) | Human expert | Model judges may assist triage but should not be the only grader |

## Judge calibration checklist

1. Sample calibration items stratified across expected passes and failures, not just random traffic.
2. Have at least two humans label a subset to measure human-human agreement; the judge cannot be expected to beat it.
3. Report judge-human agreement with the confusion matrix, not only a single number.
4. Inspect disagreements and decide whether the rubric, the judge prompt, or the human label is wrong.
5. Freeze the judge model version and rubric version together; re-calibrate whenever either changes.
6. Re-check a fresh sample periodically, because the distribution of outputs shifts as the system improves.

## Known judge biases to test

- **Position bias:** prefers the first or second option in pairwise comparisons. Mitigate by swapping order.
- **Verbosity bias:** rewards longer answers. Include concise correct answers in calibration.
- **Self-preference:** favours outputs from its own model family. Use a different family as judge when feasible, and calibrate.
- **Rubric drift:** interprets vague levels inconsistently. Anchor each level with an example.
