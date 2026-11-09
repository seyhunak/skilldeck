---
name: token-budget-estimation
description: Estimate tokens, cost, and latency per request and per month for an LLM feature from its prompt anatomy, traffic profile, caching, retries, and agent loop depth, with low, expected, and high scenarios and explicit user-verified pricing inputs. Use when budgeting a new LLM feature, comparing architectures or models on cost, or explaining why spend differs from expectations.
---

# Token Budget Estimation

## When to use
- Pricing or budgeting an LLM feature before launch.
- Comparing designs (bigger context vs retrieval, single call vs agent loop, model tiers) on cost and latency.
- Reconciling an estimate with an actual invoice or usage dashboard.

Not for: designing what goes into the context (see `context-window-management`) or a full cost reduction program (see `ai-cost-optimization-agent`).

## Inputs
- The request anatomy: system prompt, tool definitions, few-shot examples, retrieved context, conversation history, user input, and expected output.
- Traffic: requests per day or month, peak factor, growth assumption.
- Model(s) and per-token prices for input, output, and cached input, taken by the user from the provider's current pricing page, with the date checked. Prices change; this skill never supplies them as fact.
- Tokenizer access if available, or sample texts to measure.

## Procedure
1. **Measure, do not guess, token counts.** Tokenize real samples of each component with the provider's tokenizer or token-counting endpoint. Ratios such as "about four characters per token in English" are rough heuristics and vary by language, code, and tokenizer; non-English text and code often cost more tokens per character.
2. **Build the per-call model.** For each call type:
   - Input = system + tools + examples + retrieved context (chunks x chunk size) + history + user input.
   - Output = expected completion length; record median and p90, since output is usually priced higher and dominates latency.
   - Note which parts are static across calls (cache candidates).
3. **Account for multiplicity.** Requests rarely make one call. Multiply by: calls per request (router, main call, judge or guardrail call), agent loop steps (each step re-sends growing history), retry rate on errors or validation failures, and fan-out (parallel sub-calls). For agent loops, input grows per step; sum the series instead of multiplying the first step.
4. **Apply caching.** If the provider offers prompt caching, estimate the cache hit rate for the static prefix and apply the cached input price the user supplied. Include any cache write premium if the provider charges one. Without measured hit rates, model scenarios (for example 0%, 50%, 80%).
5. **Compute cost.** Cost per request = sum over calls of (uncached input x input price + cached input x cached price + output x output price). Monthly = cost per request x monthly requests. Show the formula with numbers so anyone can check it.
6. **Build scenarios.** Low, expected, and high, varying output length, history depth, retry rate, cache hit rate, and traffic. Present a sensitivity table showing which variable moves cost most.
7. **Estimate latency.** Latency is roughly time to first token plus output tokens divided by output throughput, summed over sequential calls. Use measured values from the user's own test runs where possible; label any assumed throughput.
8. **Check limits.** Compare the largest expected input against the model's context window, and peak traffic against rate limits (requests and tokens per minute).
9. **List the levers.** Rank by impact: shorter or cached system prompt, fewer retrieved chunks, output length caps, smaller model for routing or easy cases, batch processing for non-interactive work if offered, history summarization.

## Expected output
```markdown
## Token budget: <feature> (prices as supplied by user, checked <date>)
| Component | Tokens (median) | Static? |
|---|---|---|
| System + tools | 1,800 | yes |
| Retrieved context (5 x 400) | 2,000 | no |

Per request: <calls> calls, input <x> (cached <y>), output <z>
Formula: (<x-y> x P_in + <y> x P_cached + <z> x P_out) x <calls>
| Scenario | Tokens/request | Cost/request | Requests/month | Monthly cost | p50 latency |
|---|---|---|---|---|---|
| Low | | | | | |
| Expected | | | | | |
| High | | | | | |
Biggest sensitivities: ...
Limit checks: max input <n> vs context <m>; peak TPM <a> vs limit <b>
```

## Constraints and limitations
- All prices are inputs from the user; flag any figure not verified against the provider's current price page.
- Estimates are ranges for planning, not quotes; reconcile with real usage after launch.
- Tokenizers differ between model families; re-measure when switching models.
- Taxes, minimum commitments, and negotiated discounts are out of scope unless the user supplies them.

## Examples
A support copilot was estimated as one call of 3,000 input tokens. The anatomy showed a router call, a main call with 2,400 tokens of static instructions and tools, five retrieved chunks, and a guardrail call, with 8% validation retries. Expected tokens per request were about 2.6 times the original estimate; with the user's prices and a measured 70% cache hit rate on the static prefix, caching recovered roughly a third of the difference.
