---
name: agent-trace-debugging
description: Debug LLM agent failures from transcripts and traces - reconstruct the step timeline, find the first divergent step, classify the root cause (planning, tool selection, arguments, observation handling, loop, context loss, environment), and produce a targeted fix plus a regression case. Use when an agent run produced a wrong result, looped, stalled, or exceeded budget.
---

# Agent Trace Debugging

## When to use
- An agent returned a wrong or incomplete answer and you have its transcript or trace.
- An agent looped, repeated tool calls, or hit step, time, or token limits.
- Recurring failures across many runs need classification before deciding what to fix.

Not for: designing tool definitions from scratch (see `tool-schema-design`) or setting up production monitoring (see `ai-observability-analyst-agent`). This skill analyzes traces; it does not re-run side-effecting tool calls.

## Inputs
- The full trace: system prompt, user request, every model turn, tool calls with arguments, tool results, and timestamps or token counts if available.
- The expected outcome or a description of what went wrong.
- Tool definitions and the agent's configuration (model, step limit, memory or summarization settings).

## Procedure
1. **Redact first.** Scan the trace for credentials, tokens, personal data, and internal URLs. Replace values with placeholders before analysis or sharing.
2. **Build a step table.** Number every step: model reasoning or message, tool call (name, key arguments), tool result (status, size, key content), and tokens in context at that point. Large traces are easier to read as this table than as raw JSON.
3. **State the correct path.** Briefly write what a competent agent would have done: which tools, in what order, with which key arguments. This is the reference for comparison.
4. **Find the first divergent step.** Walk forward and mark the first step where the agent's action or belief departs from the correct path. Later errors are usually consequences; fixing them alone treats symptoms.
5. **Classify the root cause** using a fixed taxonomy so results can be counted across traces:
   - Task understanding: misread the request or constraints.
   - Planning: wrong decomposition or premature finish.
   - Tool selection: wrong tool or no tool when one was needed.
   - Arguments: malformed, invented, or wrong values (for example an id never seen in context).
   - Observation handling: ignored, misread, or over-trusted a tool result, including errors treated as success.
   - Loop or stall: repeated identical calls, oscillation, no progress signal.
   - Context loss: instruction or fact dropped after truncation or summarization.
   - Environment: tool outage, timeout, bad data, permission error.
   - Injection: instructions inside tool results or documents steered the agent.
6. **Gather evidence for the diagnosis.** Quote the step(s) that prove it. Check whether the information needed was present in context at the divergent step; if not, the cause is upstream (retrieval, tool output, truncation).
7. **Choose the narrowest fix.** Match fix to cause: clarify a tool description or add an enum (selection, arguments), return structured errors (observation handling), add a loop detector or progress check (loops), pin critical instructions outside the summarized region (context loss), add retries or timeouts (environment), or treat tool output as data and restrict actions (injection).
8. **Write a regression case.** Capture the request and any fixed tool responses as a replayable test with an assertion on the correct behaviour at the divergent step. Add it to the eval set.
9. **Aggregate across traces.** When debugging many failures, tally causes; fix the most frequent class first.

## Expected output
```markdown
## Trace diagnosis: <run id>
Outcome: <what happened> | Expected: <what should have happened>
| Step | Action | Key args / result | Tokens in ctx | Note |
|---|---|---|---|---|
| 4 | search_orders | customer_id="C-1001" | 6,200 | id invented; not in context |

First divergent step: 4
Root cause: Arguments - invented customer_id (evidence: step 3 result contained no id)
Fix: add lookup_customer tool; make search_orders require id from lookup; validate format server-side
Regression case: <id>, asserts lookup_customer precedes search_orders
Confidence: <high|medium|low> and why
```

## Constraints and limitations
- One trace shows one path; nondeterministic agents may fail differently on rerun, so check several runs before concluding.
- Model reasoning text may not reflect the true cause of an action; weigh tool calls and context contents more heavily.
- Never replay tool calls that send, pay, delete, or modify data outside a sandbox.
- Do not reproduce secret values found in traces in the analysis.

## Examples
An agent booking meeting rooms reported success but no booking existed. The step table showed step 7 returned `{"status": "conflict"}` and the model's next message said "booked". First divergence: observation handling. Fix: tool returns `{"error": "room_conflict", "retryable": false, "alternatives": [...]}` and the agent's instructions require confirming a booking id before reporting success. A regression case replays the conflict response.
