---
name: context-window-management
description: Decide what goes into an LLM's context window and what gets evicted - per-section token budgets, priority ordering and placement, trimming of tool outputs, rolling and structured summaries, retrieval-based long-term memory, and tests that compression keeps task-critical facts. Use for long conversations, agent loops that accumulate tool output, or requests approaching context limits or cost targets.
---

# Context Window Management

## When to use
- Chat assistants whose quality degrades or costs climb as conversations grow.
- Agent loops where tool results and history fill the context and early instructions get lost.
- Requests failing or truncating at the model's context limit.
- Designing memory for an assistant that spans sessions.

Not for: computing cost forecasts (see `token-budget-estimation`) or splitting documents for an index (see `chunking-strategy-design`).

## Inputs
- Context anatomy of a typical and a worst-case request: system prompt, tools, retrieved content, history, tool outputs, user input.
- Model context limit and the output token reservation needed.
- What the task must remember: user constraints, decisions, ids, open questions.
- Retention and privacy requirements for stored memory.

## Procedure
1. **Set a budget per section.** Start from usable input = context limit - output reservation - safety margin. Allocate fixed budgets, for example: system and tools (fixed), pinned facts and task state (small, never evicted), retrieved content (capped), recent turns (verbatim window), older history (summary), current user input (reserved). Write the budget as numbers so code can enforce it.
2. **Rank content by priority.** Typical order from highest: system instructions and safety rules; current user request; pinned task state (goals, constraints, decisions, ids); most recent turns and tool results; relevant retrieved material; older history summary; everything else. When over budget, evict from the bottom.
3. **Place content deliberately.** Models can attend unevenly across long inputs; important instructions and the current question are commonly placed at the start and repeated or restated near the end of long contexts. Put long reference material in clearly delimited blocks, and keep the query after the documents in long-document prompts. Verify placement effects on your own eval set rather than assuming them.
4. **Trim tool outputs at the source.** Return only needed fields, truncate long results with a note on how to fetch more, and replace old tool results with one-line summaries once their information has been used ("searched orders: found 3, selected #4471").
5. **Summarize history in a structured way.** Instead of free-form recaps, maintain a running state object updated every few turns: user goals, stated preferences and constraints, decisions made, facts established with sources, open questions, and pending actions. Keep the last N turns verbatim. Structured state survives repeated compression better than summaries of summaries.
6. **Use retrieval for long-term memory.** Store past exchanges or extracted facts in a searchable store and retrieve only those relevant to the current turn. Attach timestamps so newer facts override older ones, and give users a way to view and delete stored memory.
7. **Use provider features where they fit.** Prompt caching rewards a stable prefix, so keep static content first and unchanged. Some APIs offer server-side context editing or compaction; check documentation for the model in use.
8. **Test that compression preserves what matters.** Build probe cases: long conversations where a constraint stated early (for example "budget under 500", "never email my manager") must still be honoured late. Compare task success and probe accuracy for full context versus managed context. Also measure tokens per turn and latency.
9. **Instrument.** Log tokens per section per request, eviction events, and summary updates so failures can be traced to what was dropped.

## Expected output
```markdown
## Context policy: <assistant or agent>
Limit <L>, output reserve <R>, margin <M>, usable input <U>
| Section | Budget (tokens) | Priority | Eviction rule |
|---|---|---|---|
| System + tools | 2,500 | 1 | never |
| Pinned task state | 800 | 1 | never; updated every 3 turns |
| Recent turns | 6,000 | 2 | keep last 8 verbatim |
| Retrieved content | 8,000 | 3 | top chunks by score until budget |
| History summary | 1,500 | 4 | regenerate when exceeded |

State schema: goals, constraints, decisions, facts(with source), open_questions, pending_actions
Memory store: <type>, retention <days>, user controls <yes/no>
Probe results: constraint retention <x>% (full) vs <y>% (managed); tokens/turn -<z>%
```

## Constraints and limitations
- Summaries lose information; never summarize away safety rules, user constraints, or authorization decisions; keep them pinned.
- Persisted memory is user data: apply retention limits and exclude secrets and credentials from summaries.
- Larger context windows do not remove the need for management; cost and attention quality still degrade with irrelevant content.
- Budget numbers above are illustrative; size them from measured token counts.

## Examples
A travel-planning agent forgot a user's "no red-eye flights" constraint after about 40 turns because free-form summaries dropped it. Moving constraints into a pinned state object, replacing raw flight search results older than two turns with one-line summaries, and keeping six verbatim turns cut average input tokens per turn by more than half and restored constraint retention to 100% across 25 long-conversation probe cases.
