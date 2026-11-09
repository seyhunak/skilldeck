---
name: golden-dataset-construction
description: Build a versioned golden evaluation dataset for an LLM feature - coverage matrix, sourcing from production logs and targeted synthesis, edge and adversarial cases, reference labels, provenance, dev/held-out splits, and contamination checks. Use when starting evals for a feature, when existing test sets feel unrepresentative, or before comparing models or prompts.
---

# Golden Dataset Construction

## When to use
- Starting an evaluation suite for a new LLM feature.
- Existing eval cases are mostly happy paths, were written by one person, or no longer match traffic.
- Preparing a fixed benchmark before a model upgrade or a prompt optimization effort.

Not for: writing the scoring method (see `llm-judge-rubric-design`) or detailed annotator instructions (see `data-labeling-guidelines`). Generating individual cases from a prompt is covered by `eval-test-case-generator-prompt`; this skill governs the dataset as a whole.

## Inputs
- Feature spec: inputs, expected behaviour, policies, and what must never happen.
- Access to de-identified production samples, support tickets, or user research, if they exist.
- Known failure reports and bug tickets.
- Who can provide authoritative reference answers (domain experts, policy owners).

## Procedure
1. **Define the coverage matrix.** List the dimensions that change behaviour: intent or task type, input length, language, user segment, difficulty, and required behaviour (answer, ask clarifying question, refuse, escalate). The matrix rows are the cells you must populate; mark cells that are rare in traffic but high in risk.
2. **Source cases in layers.**
   - Real traffic sample (stratified, de-identified) for representativeness.
   - Failure-driven cases from bug reports and support escalations.
   - Targeted synthetic cases for empty cells: edge inputs (empty, very long, mixed language, malformed), ambiguous requests, out-of-scope requests, and adversarial inputs relevant to the feature.
   Tag every case with its source; synthetic cases should be reviewed by a person before inclusion.
3. **Size by purpose, not by habit.** A smoke set of 20-50 cases catches breakage quickly. Decision-grade comparisons usually need a few hundred cases so per-segment results are not dominated by noise. Aim for at least about 20-30 cases in any segment you intend to report separately; treat this as a rule of thumb.
4. **Write reference labels.** Depending on the task: exact answers, acceptable answer sets, required facts that must appear, forbidden content, or the correct behaviour class. Prefer "must include / must not include" checklists over a single gold paragraph for open-ended tasks. Have a second person review a sample of references; log disagreements and resolve them.
5. **Record schema and provenance.** Each case: `id`, `input` (and conversation history or retrieved context if fixed), `expected` (reference or checklist), `behaviour_class`, `tags`, `source`, `difficulty`, `created_by`, `reviewed_by`, `added_in_version`, `notes`.
6. **Split.** Keep a dev split for iteration and a held-out split that is used only for final decisions. Never copy held-out cases into prompts as few-shot examples.
7. **Check for contamination and duplication.** Remove near-duplicates (normalize and compare text, or embed and threshold similarity). Search prompts and few-shot banks for overlap with the held-out set. If public benchmark items are used, note the risk that models saw them in training.
8. **Version and govern.** Store as JSONL or CSV in version control with a changelog. Bump the version on any change; never edit a case silently, deprecate it and add a new one. Record the version with every eval result.
9. **Refresh on a schedule.** Each cycle, add cases from new failures and traffic drift, and retire cases whose expected behaviour changed due to policy updates.

## Expected output
```markdown
## Golden dataset: <feature> v<x.y>
Cases: <total> (dev <n>, held-out <m>) | sources: traffic <a>%, failures <b>%, synthetic <c>%
| Coverage cell | Cases | Risk | Notes |
|---|---|---|---|
| Refund request, non-English | 24 | high | |

Case schema: id, input, expected, behaviour_class, tags, source, difficulty, created_by, reviewed_by, added_in_version
Reference review: <n> double-reviewed, agreement <x>%
Dedup/contamination checks: <method, removed count>
Changelog: v<x.y> - added 40 cases from Q3 escalations; deprecated 6 cases after policy change
```

## Constraints and limitations
- Production data must be de-identified and used under applicable consent and retention rules before it enters a dataset.
- Synthetic cases reflect the generator's blind spots; cap their share and keep them labeled.
- A dataset tuned against repeatedly loses its value as a held-out measure; rotate held-out cases periodically.
- Do not state that a dataset is "representative" without showing the traffic sample it was compared against.

## Examples
A contract-summary feature had 60 eval cases, all short English NDAs. The coverage matrix exposed missing cells for long master agreements, scanned PDFs with OCR noise, and non-English contracts. Adding 120 cases across those cells, with clause-level must-include checklists reviewed by a lawyer, revealed that the "95% pass rate" fell to 71% on long agreements, which redirected work to chunked summarization.
