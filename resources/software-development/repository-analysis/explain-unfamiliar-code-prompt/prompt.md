# Explain Unfamiliar Code

## Intended task
Use this prompt when you are looking at a function, class, module or config file you did not write and need to understand it well enough to change it safely. It produces a layered explanation: intent first, then mechanics, then the subtle behaviour that causes bugs (side effects, error paths, ordering, concurrency, language idioms). It is built for a single excerpt of roughly 20 to 400 lines. For mapping a whole repository, use `repository-intelligence-agent` instead; for a first week on a new codebase, follow `new-codebase-onboarding-routine`.

## Required context
- **The code excerpt**, pasted verbatim with its file path. Line numbers help the model cite locations.
- **Language and framework/runtime** (for example "Python 3.12, Django 5" or "TypeScript, Node 20, NestJS"). Idioms differ sharply between ecosystems.
- **Your goal**: why you are reading it (fixing a bug, adding a feature, reviewing, porting). The explanation is weighted toward what you need to do next.
- **Your experience level** with this language, so the model knows which idioms to expand.
- Optional but valuable: signatures or short snippets of the functions it calls, the types it uses, and how it is invoked. Without them the model must guess, and it will label those guesses.

## Prompt
```text
You are a senior engineer pairing with a colleague who must understand an unfamiliar piece of code well enough to change it safely. Explain the code below in layers, from intent down to subtle behaviour. Be precise and cite line numbers. Do not pad.

Language / runtime: {{LANGUAGE_AND_RUNTIME}}
File path: {{FILE_PATH}}
Reader's goal: {{READER_GOAL}}
Reader's experience with this language: {{EXPERIENCE_LEVEL}}

Code:
{{CODE_EXCERPT}}

Surrounding context (callers, callees, types, config) if available:
{{SURROUNDING_CONTEXT}}

Rules:
- Separate what the code itself shows from what you infer about code you cannot see. Prefix inferences with "Assumption:".
- Never invent the behaviour of functions that are not shown; say what you would need to see.
- Explain language idioms only if the reader's experience level suggests they are unfamiliar.
- Prefer concrete traces ("with input X, line 14 returns Y") over abstract description.
- If something looks like a bug or a trap, say so plainly and explain the triggering input.

Produce these sections:
1. One-sentence summary: what this code is for, in domain terms.
2. Inputs, outputs and side effects: parameters, return values, mutations, I/O, network, database, global state, exceptions thrown.
3. Walkthrough: the main path in 4-10 numbered steps, each citing line ranges.
4. Control and data flow: branches, loops, early returns, and how key values change. Include one worked trace with a realistic input.
5. Non-obvious behaviour: edge cases, error handling gaps, ordering or concurrency assumptions, performance characteristics (complexity, N+1 calls, allocations), and idioms that are easy to misread.
6. Risks for the reader's goal: what is most likely to break if they change it, and what to test first.
7. Open questions: what you could not determine and which file or person would answer it.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{LANGUAGE_AND_RUNTIME}}` | Language, version and framework, e.g. "Go 1.22, net/http" | Yes |
| `{{FILE_PATH}}` | Path of the excerpt in the repository | Yes |
| `{{READER_GOAL}}` | Why you are reading it: fix bug X, add feature Y, review, port | Yes |
| `{{EXPERIENCE_LEVEL}}` | e.g. "new to Rust, fluent in Java" | Yes |
| `{{CODE_EXCERPT}}` | The code, ideally with line numbers | Yes |
| `{{SURROUNDING_CONTEXT}}` | Signatures of callees, types, callers, relevant config; write "none" if unavailable | No |

## Output format
Seven numbered sections in the order listed in the prompt, using Markdown headings. Line citations look like `L42-L57`. Inferences are prefixed with "Assumption:". The walkthrough and trace are numbered lists; risks are a bulleted list ordered by likelihood of causing a regression. Expect 400-900 words for a 100-line excerpt; much longer output usually means the model is narrating line by line, which you should push back on.

## Example usage
A developer new to Python async pastes a 60-line `retry_fetch` coroutine from `clients/http.py`, goal "add a circuit breaker". A good response summarises it as "fetches a URL with exponential backoff and jitter, giving up after five attempts"; notes in section 5 that `asyncio.sleep` inside a `try` block that catches bare `Exception` will also swallow `asyncio.CancelledError` on Python versions before 3.8 but not after (and flags that the runtime version decides which); traces an input where the server returns 503 twice then 200; and lists as a risk that the backoff state is per-call, so a circuit breaker needs state shared across calls. It ends with an open question about whether callers rely on the raised `TimeoutError` type.

## Customization
- For reviews, change section 6 to "Review concerns" and ask for severity labels.
- For porting, add a section mapping each construct to the target language.
- For very large excerpts, ask only for sections 1-3 first, then request deeper sections for chosen line ranges.
- Keep the "Assumption:" rule; removing it is the main way explanations become confidently wrong.
