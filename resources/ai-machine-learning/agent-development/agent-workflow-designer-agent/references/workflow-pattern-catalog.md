# Workflow pattern catalog

Climb from the top. Stop at the first pattern that handles every example case with acceptable quality, cost, and latency.

| # | Pattern | Use when | Avoid when | Main failure mode |
|---|---|---|---|---|
| 1 | Single call (with retrieval or tools as needed) | One judgement over inputs that fit in context | Output requires checking or several distinct skills | Prompt grows to cover too many cases |
| 2 | Prompt chain with gates | Steps are known and ordered; each output can be checked before the next | Next step depends on unpredictable discoveries | Errors propagate if gates are weak |
| 3 | Routing | Inputs fall into distinct categories that need different handling or models | Categories overlap heavily | Misrouting; measure router accuracy separately |
| 4 | Parallelization: sectioning | Independent subtasks can run at once (for example, check several policies) | Subtasks depend on each other | Aggregation step loses or double-counts findings |
| 5 | Parallelization: voting | Higher confidence is needed on one judgement; disagreement is informative | Votes are correlated (same model, same prompt) | False confidence from correlated voters |
| 6 | Orchestrator-workers | Subtasks cannot be listed in advance but the orchestrator can plan them | A fixed list of subtasks would do | Orchestrator over-decomposes; cost blow-up |
| 7 | Evaluator-optimizer | Clear evaluation criteria exist and iteration measurably improves output | No reliable evaluator; criteria are subjective | Endless refinement; cap iterations |
| 8 | Autonomous agent loop | Open-ended tasks where steps depend on environment feedback, and the environment gives ground truth (tests pass, record found) | Steps are predictable; errors are costly and hard to detect | Loops, drift, unsafe actions; requires limits and checkpoints |

## Design rules that apply to every pattern

- Keep deterministic work in code. A model should never be asked to do arithmetic, date math, or data joins that code can do exactly.
- Every model output that feeds another step has a schema and a validation check.
- Every loop has a hard limit and a defined behaviour when the limit is reached.
- Every handoff passes the minimum context needed; long transcripts are summarized with the decisions and open items preserved.
- Irreversible or externally visible actions sit behind human approval by default.

## Multi-agent decomposition heuristics

- Split by domain or permission boundary (billing agent, account agent), not by reasoning phase, when tools differ.
- Prefer a single coordinator that assigns work and collects results over peer agents negotiating with each other.
- Sub-agents return structured results, not free-form chat, so the coordinator can validate them.
- Give each sub-agent its own scoped credentials; never share an all-powerful token across agents.
