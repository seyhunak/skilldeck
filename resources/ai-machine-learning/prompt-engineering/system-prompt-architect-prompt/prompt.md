# System Prompt Architect

## Intended task
Use this when you are building or rewriting the system prompt for an LLM feature that real users will hit: a support assistant, an internal copilot, an agent with tools, a classification endpoint. You supply the requirements as you understand them; the model returns a drafted system prompt with a clear structure, a precedence order for conflicting rules, defined behavior for out-of-scope and unsafe requests, and a short list of the questions it had to assume answers to. It also emits the behaviors that should become eval cases, so the draft is never shipped untested. It is not a prompt optimizer: once you have a draft and an eval set, iterate with `prompt-optimization` instead.

## Required context
- **Product description**: what the feature does, who the users are, and the channel (chat widget, API, IDE, voice). Tone and length expectations depend heavily on channel.
- **Capabilities and tools**: the tools or data the model can access, with names exactly as the runtime exposes them. A prompt that references a tool by the wrong name is a silent failure.
- **Hard rules**: legal, policy, and brand constraints that must never be violated, separated from soft preferences. Mixing the two is the most common cause of over-refusal.
- **Known failure cases**: transcripts or descriptions of past bad outputs, if any. These become explicit instructions and eval cases.
- **Target model family** (optional): affects formatting conventions such as XML tags versus Markdown headings.

## Prompt
```text
You are a senior prompt engineer drafting a production system prompt. Your draft will be reviewed by an engineer and then tested against an eval set, so optimize for clarity, precedence, and testability rather than eloquence.

PRODUCT AND USERS:
{{PRODUCT_DESCRIPTION}}

TOOLS AND DATA THE MODEL CAN ACCESS (use these names exactly):
{{TOOLS_AND_DATA}}

HARD RULES (must never be violated):
{{HARD_RULES}}

SOFT PREFERENCES (tone, length, style; may yield to user needs):
{{SOFT_PREFERENCES}}

KNOWN FAILURE CASES TO PREVENT:
{{FAILURE_CASES}}

TARGET MODEL / FORMAT CONVENTION:
{{TARGET_MODEL}}

Work in this order:
1. Restate the job in two sentences: who the assistant serves and what a successful interaction ends with. If the requirements conflict or are too vague to write a rule, list the gap under OPEN QUESTIONS and state the assumption you used. Do not invent product facts, prices, URLs, or policy text.
2. Draft the system prompt with these sections in this order: Role and goal; Context about users and product; Capabilities and tool-use rules (when to call each tool, what to do when a tool fails or returns nothing); Hard rules; Handling out-of-scope, ambiguous, and unsafe requests (give the exact fallback behavior, not "politely decline"); Response style and format; Examples only if a behavior cannot be stated as a rule.
3. Write each rule as an observable behavior ("If the user asks for a refund status, call lookup_order before answering") rather than a trait ("be helpful"). Give the reason for non-obvious rules in one clause, because models generalize better from reasons.
4. Add a short PRECEDENCE line stating which wins when rules collide: hard rules, then safety handling, then tool-grounded facts, then user instructions, then style preferences. Adjust only if the requirements say otherwise, and say so.
5. Remove anything the model would do anyway, duplicated rules, and all-caps emphasis unless one rule genuinely needs it. Keep the prompt as short as the requirements allow.
6. List the behaviors that must be verified before launch as eval case seeds: at least one per hard rule, one per tool, one per out-of-scope category, and one per known failure case.

Return exactly the four sections described in the output format, nothing else.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{PRODUCT_DESCRIPTION}}` | What the feature does, users, channel, and what a successful session achieves | Yes |
| `{{TOOLS_AND_DATA}}` | Tool names, parameters in brief, data sources, and any retrieval context; write "none" if the model has no tools | Yes |
| `{{HARD_RULES}}` | Non-negotiable legal, policy, privacy, and brand constraints | Yes |
| `{{SOFT_PREFERENCES}}` | Tone, length, formatting, persona preferences | No |
| `{{FAILURE_CASES}}` | Past bad outputs or feared behaviors, ideally with a short transcript excerpt | No |
| `{{TARGET_MODEL}}` | Model family and whether the team prefers XML-tagged or Markdown-sectioned prompts | No |

## Output format
1. **Job statement**: two sentences.
2. **System prompt**: the full draft in a single fenced block, ready to paste.
3. **Open questions and assumptions**: a table with columns Question, Assumption used, Risk if wrong.
4. **Eval case seeds**: a numbered list, each line naming the rule it tests, a sample user input, and the expected behavior in one sentence.

## Example usage
A team building a billing assistant fills in: product "in-app chat for a B2B invoicing SaaS, admins only"; tools `lookup_invoice(invoice_id)` and `create_ticket(summary, priority)`; hard rules "never change payment methods, never quote tax advice, never reveal another tenant's data"; failure case "assistant promised a refund it cannot issue". A good response produces a prompt whose tool section says to call `lookup_invoice` before stating any amount, whose out-of-scope section routes refund requests to `create_ticket` with exact wording that promises a human follow-up rather than a refund, and an open question asking whether non-admin users can reach the widget. The eval seeds include "Can you just refund invoice 4411?" with expected behavior "creates a ticket, does not promise a refund".

## Customization
- Replace the default precedence order if your domain needs it, for example when operator instructions must outrank tool results.
- For agentic tools with many functions, add a sentence asking for a per-tool "when not to call" rule; most tool misuse is over-calling.
- If you target a model that handles long prompts poorly, add a word ceiling to step 5.
- Keep the eval seed step. Dropping it is how untested prompts reach production.
