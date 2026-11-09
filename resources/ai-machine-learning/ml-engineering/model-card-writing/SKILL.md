---
name: model-card-writing
description: Write a model card that documents model details, intended and out-of-scope uses, training and evaluation data, disaggregated performance metrics, limitations, ethical considerations, and maintenance, with every number traceable to an evaluation run. Use when releasing, handing over, or deploying a trained or fine-tuned model, or when auditing documentation of an existing model.
---

# Model Card Writing

## When to use
- Publishing a model internally or externally, including fine-tuned LLMs and classical ML models.
- Handing a model to another team or into production.
- Reviewing whether an existing model's documentation is adequate.

Not for: dataset documentation as a standalone deliverable (a datasheet is a separate artifact, though the card should link to it), or deciding whether to fine-tune at all (see `fine-tuning-readiness-agent`).

## Inputs
- Model details: architecture or base model, version, training date, owners, license.
- Training data description and provenance, including any datasheet.
- Evaluation results with dataset versions, metric definitions, and run identifiers.
- Known issues, incident reports, and red-team or fairness findings.
- Intended deployment context and users.

## Procedure
1. **Use the standard section structure.** The model card format proposed by Mitchell et al. (2019) covers: model details, intended use, factors, metrics, evaluation data, training data, quantitative analyses, ethical considerations, and caveats and recommendations. Keep these headings so readers know where to look; add a maintenance section.
2. **Write intended use concretely.** Name primary users and tasks, and explicitly list out-of-scope uses with reasons, for example "not for clinical decisions; not evaluated on patient data". Out-of-scope statements prevent the most common misuse.
3. **Describe data honestly.** Training data: sources, collection period, size, languages, preprocessing, filtering, labeling process, and known gaps or skews. Evaluation data: how it differs from training data, and whether it reflects the deployment population. Link to datasheets rather than duplicating them. If provenance is unknown, say so.
4. **Choose factors and disaggregate.** Identify factors that plausibly affect performance in the deployment context: user subgroups, languages, input conditions (image quality, document length), and environments. Report metrics per factor, with sample sizes. Do not collect or infer sensitive attributes without a lawful basis; when subgroup data is unavailable, state that the analysis was not possible.
5. **Report metrics with traceability.** For each metric give the definition, threshold if relevant, dataset and version, value, and uncertainty (confidence interval or standard deviation across seeds). Include operationally relevant metrics such as false positive and false negative rates for classifiers, calibration, latency, and model size. Every number must come from a cited run; mark anything not measured as "not evaluated".
6. **State limitations and failure modes plainly.** List conditions where performance drops, known biases, sensitivity to input shifts, and for generative models, hallucination and unsafe output tendencies observed in testing. Prefer specific statements ("accuracy falls from 0.91 to 0.74 on scanned documents") over generic disclaimers.
7. **Cover ethical and safety considerations.** Sensitive data use, potential harms and affected groups, mitigations applied, and residual risks. Note results of red-teaming or fairness reviews if done.
8. **Add maintenance information.** Owner and contact, version history, monitoring in place, retraining or review cadence, and deprecation policy.
9. **Review.** Have someone outside the training team check that every claim is supported and that out-of-scope uses are visible near the top.

## Expected output
```markdown
# Model card: <model name> v<x>
## Model details
Owner, date, version, type/base model, license, contact
## Intended use
Primary uses; primary users; out-of-scope uses (with reasons)
## Factors
Relevant groups, instrumentation, environments
## Metrics
| Metric | Definition | Why chosen |
## Evaluation data
## Training data
## Quantitative analyses
| Factor / subgroup | n | Metric | Value (95% CI) | Run id |
## Ethical considerations
## Caveats and recommendations
## Maintenance
```

## Constraints and limitations
- Do not invent or round metrics favourably; unknown values are written as unknown.
- A model card does not establish regulatory compliance; classification under laws such as the EU AI Act requires qualified legal review.
- Keep the card versioned with the model; a stale card is worse than none.
- Remove confidential training details only by noting the omission, not by misdescribing the data.

## Examples
A document-classification model card originally reported a single accuracy of 0.93. Disaggregating by document source showed 0.95 on digital PDFs and 0.78 on phone photos (n=410). The card now lists phone-captured documents as a known limitation, recommends human review below a confidence of 0.8, and records the evaluation run ids for both numbers.
