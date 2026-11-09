# MCP server design checklist

Run through this before handing a design to implementers. Items about protocol mechanics must be verified against the specification revision in use.

## Toolset
- [ ] Every tool maps to at least one real user task.
- [ ] No two tools could plausibly be chosen for the same request; overlaps are merged or their descriptions say when to use which.
- [ ] Tool names are verb-led, specific, and unlikely to collide with tools from other servers loaded in the same client (consider a short service prefix).
- [ ] Read-only and write tools are separate.
- [ ] The total toolset is small enough that a model can hold all descriptions in mind; split the server if not.

## Descriptions
- [ ] States what the tool does, when to use it, when not to use it, and what it returns.
- [ ] Mentions important limits (page size, date ranges, required permissions).
- [ ] Avoids internal jargon the model cannot know; defines domain terms briefly.
- [ ] Is static; changes are versioned and visible to users.

## Input schemas
- [ ] Closed sets use enums; free text is used only where necessary.
- [ ] Identifiers state their format and where the model can obtain them (for example, from a search tool).
- [ ] Dates and times state format and time zone.
- [ ] Optional parameters have sensible defaults described in the schema.
- [ ] Parameter descriptions include a short example value.

## Outputs
- [ ] Concise by default, with options for more detail.
- [ ] Paginated with a cursor and an explicit "more results" signal.
- [ ] Includes stable identifiers the model can pass to follow-up tools.
- [ ] Truncation is announced, never silent.
- [ ] Untrusted user-generated or external content is clearly delimited as data.

## Errors
- [ ] Execution errors are returned as readable tool results, not only protocol failures.
- [ ] Messages say what to do next (valid values, correct tool, missing permission).
- [ ] No stack traces, internal hostnames, or secrets in messages.

## Security and operations
- [ ] Server acts with the end user's permissions, enforced server-side.
- [ ] Destructive and externally visible tools require client-side user confirmation.
- [ ] Tokens are scoped to this server; client tokens are not forwarded blindly to downstream services.
- [ ] Local HTTP servers validate connection origin and bind to localhost.
- [ ] Rate limiting and timeouts protect the underlying system.
- [ ] Tool calls are logged with redacted arguments, user, outcome, and latency.

## Evaluation
- [ ] A task set of realistic requests exists, including ambiguous ones.
- [ ] Measures: correct tool selected, valid arguments, calls per task, recovery after error.
- [ ] Results are rechecked after every change to names or descriptions.
