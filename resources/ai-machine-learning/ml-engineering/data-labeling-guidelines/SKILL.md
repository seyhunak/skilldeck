---
name: data-labeling-guidelines
description: Write annotation guidelines with precise label definitions, decision rules, boundary and counter-examples, and an escalation path, then pilot them, measure inter-annotator agreement (Cohen's kappa, Fleiss' kappa, or Krippendorff's alpha), adjudicate disagreements, and revise before scaling. Use when starting a labeling project for training or evaluation data, or when label quality is suspect.
---

# Data Labeling Guidelines

## When to use
- Starting human annotation for training data, evaluation sets, or judge calibration.
- Annotators disagree often, or model errors trace back to inconsistent labels.
- Handing a labeling task to a vendor or a new annotator pool.

Not for: designing the overall eval dataset (see `golden-dataset-construction`) or writing an LLM judge rubric (see `llm-judge-rubric-design`), although the same guideline can serve both humans and a judge.

## Inputs
- The downstream purpose of the labels and the decision they support.
- A draft label set and 100+ unlabeled sample items covering the expected variety.
- Annotator profile: domain experts, trained generalists, or crowd workers, and their languages.
- Sensitivity of the content (personal data, disturbing material).

## Procedure
1. **Start from the decision, then the label set.** Write one sentence on how labels will be used. Keep only labels that change that use. Make labels mutually exclusive for single-label tasks, or state explicitly that the task is multi-label. Include an "unclear / cannot determine" option with criteria for when to use it, so annotators do not guess.
2. **Define each label operationally.** For every label give: a definition based on observable features of the item, inclusion criteria, exclusion criteria, and the nearest confusable label with the rule that separates them. Avoid definitions that depend on guessing intent unless intent is what you are labeling.
3. **Write decision rules for known hard cases.** A short ordered decision tree ("first check X; if yes, label A regardless of Y") resolves most conflicts. Add precedence rules for items that match several labels.
4. **Add examples, especially boundary ones.** For each label: two or three clear examples, two or three borderline examples with explanations, and counter-examples that look similar but belong elsewhere. Boundary examples do more for consistency than clear ones.
5. **Specify the workflow.** Unit of annotation (document, sentence, span), tool instructions, how to handle malformed items, time expectations, escalation channel for questions, and how guideline updates are announced and versioned.
6. **Include handling and wellbeing rules.** Instructions for personal data (do not copy or export it), and for disturbing content: content warnings, opt-out, exposure limits, and access to support.
7. **Pilot and measure agreement.** Have at least two or three annotators independently label the same 50-100 items. Compute agreement with a chance-corrected statistic: Cohen's kappa for two annotators, Fleiss' kappa for a fixed number of annotators per item, or Krippendorff's alpha for missing labels, multiple annotators, or ordinal and interval scales. Report per-label agreement and a confusion matrix between annotators, not only the overall figure. Common interpretation bands exist (for example kappa above roughly 0.8 is often treated as strong), but they are conventions; set the acceptance bar by the task's needs.
8. **Adjudicate and revise.** An adjudicator, usually the guideline author or a domain expert, resolves each disagreement and records the reason. Group reasons: unclear definition, missing rule, missing example, annotator error. Update the guideline for the first three; retrain for the last. Re-pilot on fresh items until agreement meets the bar.
9. **Monitor at scale.** Seed gold items with known labels into production batches, keep a percentage double-labeled for ongoing agreement, and review annotators whose gold accuracy drifts.

## Expected output
```markdown
# Labeling guideline: <task> v<x>
Purpose: <how labels are used>
## Labels
### <Label A>
Definition | Include when | Exclude when | Not to be confused with <B> because ...
Clear examples | Borderline examples (with reasoning) | Counter-examples
## Decision procedure
1. ... 2. ...
## Workflow, escalation, and versioning
## Data handling and wellbeing
## Pilot results
Annotators <n>, items <m>, statistic <kappa/alpha> = <v>; per-label: ...
Top disagreement causes and changes made in this version
```

## Constraints and limitations
- High agreement can mean a shared misunderstanding; validate a sample against expert judgment too.
- Kappa is sensitive to label prevalence; for rare labels also report per-label precision and recall against adjudicated gold.
- Guideline changes mid-project create inconsistent labels; version them and relabel affected items if needed.
- Annotator compensation and employment terms are outside the scope of this skill.

## Examples
A toxicity labeling pilot reached kappa 0.52. The disagreement matrix showed most conflicts between "insult" and "profanity without target". Adding a rule ("insult requires an identifiable target; profanity alone is labeled profanity") plus six borderline examples raised kappa to 0.78 on a fresh 80-item pilot, after which the project scaled with 5% gold items seeded per batch.
