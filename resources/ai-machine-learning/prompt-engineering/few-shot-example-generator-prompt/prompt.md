# Few-Shot Example Generator

## Intended task
Use this when a prompt needs in-context examples and you do not yet have a curated set: a ticket classifier, an entity extractor, a rewriting task with a house style. The model plans the examples against diversity axes you name (length, register, label, edge type), writes them with labels and the gold output, and flags the ones that sit near a decision boundary. The result is a candidate set for a human to review, not a finished training set. If you need a large evaluation dataset with versioning and annotator agreement, use `golden-dataset-construction`; if you need test cases rather than demonstrations, use `eval-test-case-generator-prompt`.

## Required context
- **Task definition**: the exact instruction the examples will accompany, so demonstrations match the real prompt format.
- **Label set or output schema**: every allowed label with a one-line definition, or the JSON schema of the expected output. Undefined labels produce inconsistent examples.
- **Diversity axes**: the dimensions real inputs vary on. If you don't know them, give three or four real (anonymized) inputs and let the model infer axes.
- **Count**: how many examples fit your token budget. Three to eight is typical; more rarely helps and costs tokens on every call.

## Prompt
```text
You are designing few-shot demonstrations for a production prompt. Demonstrations will be pasted verbatim into the prompt, so their format must match the real task exactly, and every label must be defensible to a domain reviewer.

TASK INSTRUCTION THE EXAMPLES WILL ACCOMPANY:
{{TASK_INSTRUCTION}}

LABELS OR OUTPUT SCHEMA (with definitions):
{{LABELS_OR_SCHEMA}}

DIVERSITY AXES (how real inputs vary):
{{DIVERSITY_AXES}}

SAMPLE REAL INPUTS FOR STYLE REFERENCE (anonymized; do not copy them):
{{SAMPLE_INPUTS}}

NUMBER OF EXAMPLES: {{EXAMPLE_COUNT}}

Procedure:
1. Build a coverage plan first: a table assigning each planned example a label and a value on each diversity axis. Every label must appear at least once; no label may take more than half the slots unless only two labels exist. Spread input length from short to long.
2. Reserve at least one slot in four for a hard case: an input that sits near the boundary between two labels, contains a misleading surface cue, or omits information the output must handle (for example a missing field that should be null, not guessed).
3. Write each example in the exact input/output format of the task. Inputs must read like real user text for this domain, with natural noise such as typos or mixed topics where the axes call for it. Do not reuse distinctive phrases across examples; a repeated phrase teaches the model a spurious cue.
4. For each example, write a one-line rationale: which axis or boundary it covers and why the label is correct under the given definitions.
5. Self-check: list any pair of examples whose labels could be swapped by a reasonable annotator, and any label definition that turned out ambiguous while writing. Do not resolve ambiguity silently; report it.
6. Recommend an ordering for the final prompt. Do not end with a run of the same label, since the last examples have outsized influence on many models.

Do not invent facts about real people, companies, or products. Use clearly fictional names.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{TASK_INSTRUCTION}}` | The instruction text the examples will sit beside, including input/output format | Yes |
| `{{LABELS_OR_SCHEMA}}` | Allowed labels with definitions, or the output JSON schema with field rules | Yes |
| `{{DIVERSITY_AXES}}` | Dimensions such as length, tone, language, channel, product area, edge type | Yes |
| `{{SAMPLE_INPUTS}}` | Two to five anonymized real inputs, or "none" | No |
| `{{EXAMPLE_COUNT}}` | Target number of examples, typically 3 to 8 | Yes |

## Output format
1. **Coverage plan**: table with columns #, Label, one column per axis, Hard case (yes/no).
2. **Examples**: numbered, each with Input, Output, Rationale.
3. **Ambiguity report**: swappable pairs and unclear definitions.
4. **Recommended order**: list of example numbers with one sentence of reasoning.

## Example usage
For a support-ticket router with labels `billing`, `bug`, `how_to`, `account_access`, axes "length, frustration level, product area, mentions multiple issues", and count 6, a good response plans one example per label plus two hard cases: a locked-out user who mentions an unpaid invoice (boundary between `account_access` and `billing`, labeled `account_access` because the definitions say route by what blocks the user), and a "feature doesn't work" message that is actually a how-to question. The ambiguity report notes that `bug` versus `how_to` depends on whether the documented behavior was met, and asks the owner to add that test to the label definition.

## Customization
- For extraction tasks, add an axis for "fields missing from input" so the model learns to emit null rather than hallucinate.
- For multilingual products, make language an axis and ask for outputs in the language your system actually returns.
- If examples must be drawn from real data instead of synthesized, change step 3 to "select and lightly anonymize from SAMPLE_INPUTS" and keep the coverage plan.
- Re-run the ablation in `prompt-optimization` after inserting examples; demonstrations sometimes reduce quality on inputs unlike any example.
