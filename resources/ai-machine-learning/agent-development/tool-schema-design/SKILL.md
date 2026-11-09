---
name: tool-schema-design
description: Design function or tool definitions that language models call reliably - tool boundaries and granularity, names, descriptions, JSON Schema parameters with enums and constraints, actionable error payloads, idempotency, and side-effect confirmation - plus a test plan for tool selection accuracy. Use when defining tools for an agent, reviewing an existing tool set, or debugging wrong tool choices and malformed arguments.
---

# Tool Schema Design

## When to use
- Defining tools for a new agent or function-calling feature.
- An agent picks the wrong tool, invents argument values, or loops after tool errors.
- Exposing an existing API to a model and deciding how much of it to expose.

Not for: designing a full MCP server with auth and transport (see `mcp-server-design-agent`), or extracting structured data from documents without calling anything (see `structured-output-extraction`).

## Inputs
- The tasks the agent must accomplish and the underlying APIs or functions.
- Which operations have side effects (writes, payments, messages, deletions).
- Representative user requests, including ambiguous ones.
- The model and provider tool-calling format in use.

## Procedure
1. **Design tools around user intents, not endpoints.** One tool per distinct decision the model makes. Merge endpoints the model would always call together (for example look up customer then fetch orders) into one higher-level tool; split a tool whose behaviour changes radically by a mode flag. Keep the total small enough that descriptions do not blur; if the set grows large, group tools or load them by context.
2. **Name clearly and distinctly.** Use `verb_noun` names in one consistent style (`search_orders`, `refund_order`). Avoid near-synonyms across tools (`get_order` and `fetch_order`). Namespacing by service helps when many tools coexist.
3. **Write the description as instructions to the model.** State what the tool does, when to use it, when not to use it (naming the alternative tool), what it returns, and important limits (pagination, max results, latency). Two to five sentences is typical. Include a short example of a correct call when arguments are non-obvious.
4. **Constrain parameters with the schema.**
   - Use `enum` for closed sets, `format` and `pattern` for ids and dates, `minimum`/`maximum` for numbers.
   - Mark only truly required fields as `required`; give optional fields documented defaults.
   - Describe every parameter, including units and formats (`ISO 8601 date, UTC`).
   - Prefer flat objects; deep nesting increases malformed calls.
   - Do not ask the model for values it cannot know (internal ids it has not seen); provide a lookup tool instead.
5. **Return model-friendly results.** Return concise, relevant fields rather than raw API dumps; include ids the model will need for follow-up calls; truncate large results and say how to get more.
6. **Make errors actionable.** Return structured errors such as `{"error": "invalid_date_range", "message": "end_date must be after start_date", "hint": "..."}`. Distinguish retryable from non-retryable errors so the agent does not loop.
7. **Declare side effects.** For tools that change state: support idempotency keys where the backend allows, provide a dry-run or preview variant when practical, and require explicit human confirmation in the application layer before irreversible actions. Do not rely on the description alone to prevent misuse.
8. **Test tool selection.** Build 30+ requests labeled with the expected tool and key arguments, including requests that should call no tool and ambiguous ones that should trigger a clarifying question. Measure tool-choice accuracy and argument validity, then revise descriptions for the confused pairs.

## Expected output
```markdown
## Tool set: <agent name>
| Tool | Intent | Side effects | Confirmation | Replaces endpoints |
|---|---|---|---|---|
| refund_order | Issue full/partial refund | Moves money | Human approval required | POST /refunds |

### refund_order
Description: ...
Parameters (JSON Schema): {"type": "object", "properties": {...}, "required": [...]}
Returns: ...
Errors: invalid_amount (non-retryable), payment_gateway_timeout (retryable, max 2)

Selection test (n=<n>): tool accuracy <x>%, valid args <y>%; confused pairs: ...
```

## Constraints and limitations
- Schemas reduce but do not eliminate malformed arguments; validate server-side every time.
- Provider support for JSON Schema keywords varies; check which keywords your provider enforces.
- Tool descriptions are visible to the model and may be visible to users; keep secrets out of them.
- Authorization belongs in the backend, not in the prompt.

## Examples
An agent with `get_ticket`, `fetch_ticket_details`, and `lookup_case` chose wrongly in 30% of test requests. Merging them into `get_ticket(ticket_id, include=[...enum...])`, adding "do not use for searching; use search_tickets" to the description, and returning structured not-found errors raised tool-choice accuracy to 96% on the 40-request test set.
