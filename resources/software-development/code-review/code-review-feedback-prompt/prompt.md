# Code Review Feedback

## Intended task
Use this prompt after you have reviewed a change and jotted rough notes ("this leaks", "naming??", "why not use the existing helper"). It turns those notes into review comments an author can act on without a follow-up conversation: anchored to a location, explaining the concern and its impact, suggesting a concrete fix, and labelled so the author knows what blocks the merge. It rewrites wording only; the judgement stays yours. For finding the issues in the first place use the `structured-code-review` skill or `pull-request-review-agent`, and for the end-to-end reviewer workflow see `pull-request-review-routine`.

## Required context
- **Your raw notes**, one per line, with file and line references where you have them.
- **The relevant diff hunks** so the model can quote code accurately and propose fixes that fit.
- **Team conventions** for comment labels (for example Conventional Comments) and what counts as blocking.
- **The relationship and context**: first-time contributor, senior peer, urgent hotfix. Tone and the amount of explanation should adapt.

## Prompt
```text
You are a senior engineer known for code reviews that are direct, kind and easy to act on. Rewrite my rough review notes into final review comments. Preserve my technical judgement exactly: do not add new findings, do not drop any note, and do not change a note's severity unless I marked it with "?" meaning I am unsure.

Pull request summary: {{PR_SUMMARY}}
Author context: {{AUTHOR_CONTEXT}}
Label scheme and blocking rules: {{LABEL_SCHEME}}

My raw notes:
{{RAW_NOTES}}

Relevant diff hunks:
{{DIFF_HUNKS}}

For each note, write one comment with:
- Location: file and line (or "general").
- Label: from the scheme, e.g. blocking issue, suggestion, question, nitpick, praise.
- Comment: 1-4 sentences. Describe the code, not the person ("this loop", not "you"). State the concern, then the concrete impact (bug, security, performance, maintainability, readability). Ask a genuine question when I was unsure.
- Suggestion: a specific change, with a short code snippet when it helps. Use the diff's language and style.

Then:
- Merge a duplicate or overlapping note into one comment and say which notes were merged.
- Write a 2-4 sentence summary comment: overall assessment, the blocking items in priority order, and one genuine positive if my notes contain one. Do not invent praise.
- List any note you could not rewrite confidently because the diff did not support it.

Style rules: no sarcasm, no "just", no "obviously", no "why didn't you". Avoid hedging on blocking items: a security or correctness problem stays clearly blocking. Keep nitpicks short and explicitly optional.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{PR_SUMMARY}}` | One or two lines on what the change does | Yes |
| `{{AUTHOR_CONTEXT}}` | e.g. "new team member, first PR", "senior peer, hotfix under time pressure" | Yes |
| `{{LABEL_SCHEME}}` | Labels and which ones block merge; e.g. "Conventional Comments; only issue(blocking) blocks" | Yes |
| `{{RAW_NOTES}}` | Your notes, one per line, `?` marking uncertainty | Yes |
| `{{DIFF_HUNKS}}` | The code the notes refer to | Yes |

## Output format
A numbered list of comments, each as:

```text
[label] path/to/file.ext:L120
Comment text.
Suggestion: ...
```

followed by a "Summary comment" block and a "Could not rewrite" list (or "none"). Each comment should be postable as-is.

## Example usage
Raw note: `orders.py 88 - n+1, kills list page`. Output: `[issue (blocking)] orders/views.py:L88` "This loop calls `order.customer` for each order, which issues one query per row; on the 200-row list page that is roughly 200 extra queries per request." Suggestion: add `.select_related("customer")` to the queryset on L81. Raw note `naming? data2` becomes a short optional nitpick asking whether `pending_refunds` would describe the variable better.

## Customization
- Replace the label scheme with your team's own (for example "must / should / could").
- For open-source contributors, ask for an extra sentence linking to the contributing guide on convention issues.
- For async teams across time zones, ask the model to turn questions into "question + default assumption" so the author can proceed without waiting.
