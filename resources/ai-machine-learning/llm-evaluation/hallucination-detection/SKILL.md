---
name: hallucination-detection
description: Detect unsupported or fabricated content in LLM outputs by decomposing the output into atomic claims, retrieving or locating evidence for each in the supplied sources, labeling each claim supported, contradicted, or not verifiable, and reporting per-answer findings plus faithfulness rates. Use for auditing RAG answers, summaries, reports, and citations before they reach users or as an evaluation metric.
---

# Hallucination Detection

## When to use
- Auditing a RAG answer, summary, or generated report against its source documents.
- Checking that citations actually support the sentences they are attached to.
- Building a faithfulness metric for an evaluation suite or production sampling.

Not for: judging style or helpfulness (see `llm-judge-rubric-design`) or measuring whether the retriever found the right documents (see `retrieval-quality-metrics`). This skill checks the output against evidence; it is not open-ended fact-checking against the whole web.

## Inputs
- The output to check.
- The evidence set: retrieved passages, source documents, or a trusted reference. For closed-book outputs, the user must name an authoritative reference; without one, claims can only be marked not verifiable.
- The definition of "supported" for this use (strict entailment, or allowed paraphrase and common knowledge).

## Procedure
1. **Fix the standard of support.** Decide up front: is general background knowledge allowed, or must every factual claim be grounded in the sources? For RAG features grounded-only is usually the right standard. Write the rule down so labels are consistent.
2. **Extract atomic claims.** Split the output into the smallest independently checkable statements. "Acme was founded in 2009 in Berlin by two engineers" becomes three claims. Resolve pronouns so each claim stands alone. Skip non-factual content (greetings, hedges, opinions marked as such) but keep implicit claims, such as a recommendation that presupposes a fact.
3. **Locate evidence for each claim.** Search the evidence set for the passage(s) that bear on the claim. Quote the exact span. If the output cites a source, check the cited source first, then the others.
4. **Label each claim.**
   - Supported: the evidence entails the claim.
   - Contradicted: the evidence states something incompatible.
   - Not verifiable: no evidence either way (this is a hallucination under a grounded-only standard).
   - Partially supported: some elements match, others do not; record which element fails.
   Pay special attention to high-risk categories: numbers, dates, names, quotations, citations, causal claims, and negations.
5. **Check citations separately.** For each citation, record whether the cited passage supports the sentence it is attached to. A true claim attached to the wrong source is a citation error, not a factual one, and needs a different fix.
6. **Aggregate.** Faithfulness = supported claims / checkable claims. Also report the share of answers with at least one contradicted or unverifiable claim, since users experience answers, not claims. Break down by claim type.
7. **Automate carefully.** An LLM can perform steps 2-4 with a natural-language-inference style prompt per claim (premise = evidence span, hypothesis = claim). Calibrate it on a human-labeled sample of claims before trusting its rates, and keep a human review sample in production.
8. **Feed fixes back.** Map findings to causes: retrieval missed the evidence, the generator ignored it, the prompt allowed background knowledge, or the source itself was wrong.

## Expected output
```markdown
## Hallucination audit: <output id>
Standard: <grounded-only | background allowed>
| # | Claim | Label | Evidence (quote, source) | Note |
|---|---|---|---|---|
| 1 | Plan includes 5 seats | Contradicted | "The Team plan includes 3 seats" (pricing.md) | number error |
| 2 | Annual billing gets a discount | Not verifiable | none found | |

Citation check: 4/5 citations support their sentence
Faithfulness: 7/9 checkable claims supported (0.78)
Likely cause: generator added background knowledge; retrieval did contain the correct seat count
```

## Constraints and limitations
- Never mark a claim supported from your own knowledge when the standard is grounded-only; mark it not verifiable.
- Claim extraction is itself error-prone; inconsistent granularity skews rates, so keep extraction rules fixed across comparisons.
- Sources can be wrong or outdated; a supported claim is faithful to the source, not necessarily true.
- For medical, legal, or financial content, automated checks support but do not replace expert review.

## Examples
A policy assistant answered a parental-leave question with six claims. Five matched the HR policy; one ("leave can be split into three blocks") was not verifiable, since the policy only mentioned two blocks. The retrieved context contained the correct rule, so the fix targeted the generation prompt (forbid adding unstated conditions) rather than retrieval.
