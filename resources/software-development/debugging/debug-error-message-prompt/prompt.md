# Debug an Error Message

## Intended task
Use this prompt when you have an error, exception or failing output and want the next steps ranked rather than a single guessed fix. It classifies the error, finds the first frame that belongs to your code, generates competing hypotheses, ranks them by likelihood and cost to test, and gives a discriminating check for each. It suits local and CI errors and single-service production exceptions. For a live multi-service outage use `production-incident-debugger-agent`; for deep reading of traces across languages see the `stack-trace-analysis` skill; for intermittent ordering problems see `concurrency-bug-analysis-agent`.

## Required context
- **The full error output**, including the complete stack trace and any "caused by" chain. Truncated traces are the most common reason for wrong diagnoses.
- **What you were doing**: command run, request sent, test executed, and the expected result.
- **Environment**: language and runtime version, framework, OS, container or CI runner, and relevant dependency versions.
- **What changed recently**: deploys, dependency bumps, config or data changes. "Nothing changed" is also useful information.
- **Frequency**: every time, intermittent, only in one environment.
- **The code** at the top in-house frames, and anything you have already tried.

## Prompt
```text
You are an experienced debugger. Your job is to shorten the path to the root cause, not to guess a fix. Reason from evidence, and keep hypotheses that compete until a check rules them out.

Error output (verbatim, full trace):
{{ERROR_OUTPUT}}

What I was doing and what I expected:
{{ACTION_AND_EXPECTATION}}

Environment (runtime, versions, OS, container/CI):
{{ENVIRONMENT}}

Recent changes:
{{RECENT_CHANGES}}

Frequency and reproducibility:
{{FREQUENCY}}

Relevant code (top in-house frames) and what I already tried:
{{CODE_AND_ATTEMPTS}}

Steps:
1. Restate the error in one sentence: exception type, message, and where it surfaced.
2. Classify it: syntax/compile, dependency/import, configuration/environment, type or null, data/validation, resource (memory, file handles, disk, ports), network/timeout, permission/auth, concurrency/ordering, or upstream/library bug. Give the evidence for the class.
3. Locate the trace: identify the first frame in the user's own code, the frame where the error was raised, and any wrapping or re-raising that hides the original cause.
4. Hypotheses: list 3-5 distinct explanations. For each give: supporting evidence, contradicting evidence, likelihood (high/medium/low), and the cheapest check that would confirm or eliminate it (a command, log line, breakpoint, print, or one-line experiment). Rank by likelihood divided by cost of checking.
5. Recommended next check: the single check to run first and what each possible result would mean.
6. Probable fix for the top hypothesis, as a minimal change, plus how to verify it and what regression test to add.
7. Missing information: what extra output would most change your ranking.

Rules: do not invent library behaviour or version-specific facts you are unsure of; flag them as "Unverified". Do not recommend disabling checks, security controls, or tests as a fix. If secrets appear in the input, do not repeat them.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{ERROR_OUTPUT}}` | Full error text and stack trace, secrets redacted | Yes |
| `{{ACTION_AND_EXPECTATION}}` | What you ran and what should have happened | Yes |
| `{{ENVIRONMENT}}` | Runtime and dependency versions, OS, container or CI details | Yes |
| `{{RECENT_CHANGES}}` | Deploys, upgrades, config or data changes, or "none known" | Yes |
| `{{FREQUENCY}}` | Always, intermittent (with rate), or environment-specific | Yes |
| `{{CODE_AND_ATTEMPTS}}` | Code at the relevant frames and fixes already tried | No |

## Output format
Seven numbered sections. Section 4 is a table: `# | Hypothesis | For | Against | Likelihood | Cheapest check`. Section 5 is a short decision list ("if X, then hypothesis 2; if Y, then 1"). Section 6 contains a minimal diff or code block. Unverified claims are explicitly labelled.

## Example usage
Input: `psycopg2.OperationalError: FATAL: remaining connection slots are reserved` in a Django app, intermittent since moving to a larger worker count, on PostgreSQL 15. A good answer classifies it as resource exhaustion, ranks "workers x pool size exceeds `max_connections` minus reserved slots" first with the check `SELECT count(*), state FROM pg_stat_activity GROUP BY state;` during load, ranks "connections leaked by a background thread that never closes them" second (check: idle connections whose `backend_start` keeps growing old), and "`CONN_MAX_AGE` set high with many idle workers" third. The suggested fix computes the connection budget explicitly and suggests a pooler, and asks for the worker and pool configuration as missing information.

## Customization
- For CI-only failures, add the runner image and a diff of environment variables between local and CI.
- For frontend errors, include browser, bundler and source-map status.
- For a known-flaky test, pair it with the `flaky-test-diagnosis` skill.
- Shorten to sections 1, 4 and 5 when you only want the triage.
