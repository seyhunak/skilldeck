# LLM Output Critique

## Intended task
Use this to grade a single model output against a rubric you already have, either during prompt iteration ("why did this answer feel off?") or as the judge prompt inside an eval harness. The model quotes the parts of the output that drive each score, scores dimensions one at a time on anchored levels, marks any hard-rule violation as a gating failure, and suggests the smallest change to the prompt or output that would fix each problem. It is pointwise, comparing one output to a standard; for choosing between two outputs, or for designing the rubric itself and calibrating it against humans, use `llm-judge-rubric-design`.

## Required context
- **Original task input**: the user message and any context the model saw. Grading without the input rewards fluent but irrelevant answers.
- **Output to critique**: verbatim, including formatting.
- **Rubric**: dimensions with level anchors (what a 1, 3, and 5 look like), plus hard rules that fail the output regardless of other scores.
- **Reference material** (optional): a reference answer or source documents. If supplied, the judge can check correctness; if not, it must say correctness was not verifiable.

## Prompt
```text
You are a strict, evidence-driven evaluator. You grade one output against the rubric below. You do not reward length, confidence, or polish unless the rubric asks for them. You never assume facts that are not in the input or reference material.

TASK INPUT GIVEN TO THE MODEL:
{{TASK_INPUT}}

OUTPUT TO EVALUATE:
{{MODEL_OUTPUT}}

RUBRIC (dimensions with level anchors):
{{RUBRIC}}

HARD RULES (any violation fails the output):
{{HARD_RULES}}

REFERENCE ANSWER OR SOURCES (may be "none"):
{{REFERENCE}}

Procedure:
1. Check each hard rule first. For each, quote the exact span that violates it or write "no violation". A violation sets overall_pass to false regardless of dimension scores.
2. For each rubric dimension separately: quote one to three short spans of the output that are the strongest evidence, explain in at most two sentences how they map to the level anchors, then give the score. Write the evidence before the score.
3. Score each dimension independently. A weakness in one dimension must not lower another dimension's score unless the rubric says the dimensions are linked.
4. If a dimension cannot be judged from the material (for example factual accuracy with no reference), score it null and say what would be needed.
5. For every dimension scored below the top level, propose one concrete fix: either an edit to the output or a change to the instruction that likely caused the problem. Prefer the smallest fix.
6. Do not compute an average unless the rubric defines weights. If weights are given, compute the weighted score and show the arithmetic.

Return only the JSON object described, with no text before or after it.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{TASK_INPUT}}` | The prompt, user message, and context the evaluated model received | Yes |
| `{{MODEL_OUTPUT}}` | The output being graded, verbatim | Yes |
| `{{RUBRIC}}` | Dimensions with anchored level descriptions and optional weights | Yes |
| `{{HARD_RULES}}` | Non-negotiable constraints such as "no medical dosage advice" or "valid JSON", or "none" | Yes |
| `{{REFERENCE}}` | Reference answer or source documents, or "none" | No |

## Output format
A single JSON object:

```json
{
  "hard_rule_checks": [{"rule": "...", "violated": false, "evidence": "..."}],
  "dimensions": [{"name": "...", "evidence": ["..."], "reasoning": "...", "score": 4, "fix": "..."}],
  "weighted_score": null,
  "overall_pass": true,
  "unverifiable": ["..."],
  "summary": "one sentence"
}
```

Store `evidence` with scores in your eval logs; when human and judge scores disagree, the quoted spans show which side misread the output.

## Example usage
A support reply is graded on Accuracy, Completeness, and Tone (anchors 1 to 5) with hard rule "must not promise refunds". The output says "I've gone ahead and processed your refund". A good critique flags the hard rule with that quote and sets `overall_pass` to false, then still scores Tone 4 with evidence of an apologetic, clear opening, scores Accuracy null because no account data was supplied, and proposes the fix "replace with: I've opened a refund request; the billing team will confirm within two business days" plus an instruction change adding the refund rule to the system prompt's tool section.

## Customization
- Use integer scales with three to five anchored levels; finer scales usually add noise rather than resolution.
- Run the judge on a sample already labeled by humans and measure agreement before trusting it at scale.
- To reduce self-preference, use a different model family as the judge than the one being graded, where practical.
- For pairwise comparison, do not adapt this prompt by pasting two outputs; position bias needs order swapping, which a pairwise template handles.
