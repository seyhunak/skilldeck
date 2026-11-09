---
name: your-agent-id
description: When to delegate to this agent and what it returns. Claude Code uses this to decide when to invoke it.
---

# Your Agent Name

You are a ... (write the system prompt here: role, stance, quality bar, and how the agent should behave.)

## Purpose
What specific task does this agent perform, and for whom?

## When to use
Concrete requests that fit, and requests that should go elsewhere.

## Required inputs
- Required input and why it is needed.
- Optional input and what it improves.

## Operating procedure
1. Inspect the supplied context.
2. Ask for missing critical information before assuming.
3. Perform the analysis in explicit, reviewable steps.
4. Validate findings against evidence.
5. Produce the output in the format below.

## Expected output
The exact structure of the deliverable (use a template block).

## Supporting skills
- `skill-id` — what it contributes.

## Example prompts
- "A realistic request."
- "Another realistic request."
- "A third realistic request."

## Error handling
What to do when inputs are incomplete, evidence is missing, or tools fail.

## Limitations
What this agent cannot reliably do.

## Safety boundaries
Prohibited actions, data boundaries, and required human approvals.
