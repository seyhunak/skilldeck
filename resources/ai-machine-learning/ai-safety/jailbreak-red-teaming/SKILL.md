---
name: jailbreak-red-teaming
description: Plan and run an authorized adversarial test of your own LLM application - written scope and rules of engagement, threat model, attack-category coverage matrix, test cases built around benign canary objectives, consistent severity scoring, and remediation with regression tests. Use before launching or materially changing an LLM feature you own or are explicitly permitted to test. Not for attacking third-party systems.
---

# Jailbreak Red Teaming

## When to use
- Pre-launch safety testing of an LLM application your organization owns.
- After changing the model, system prompt, tools, or guardrails of that application.
- Building a recurring adversarial regression suite for your own product.

Not for: testing systems you do not own or lack written permission to test, obtaining harmful content from any model, or bypassing a provider's usage policies. For deep analysis of indirect prompt injection and data exfiltration paths use `prompt-injection-assessment-agent`; for designing the defences themselves use `ai-guardrails-design-agent`.

## Inputs
- Written authorization naming the application, environments, time window, and testers.
- The application's policies: what it must refuse, what data it can access, what actions its tools can take.
- Architecture: system prompt location, retrieval sources, tools and their side effects, memory, and existing filters.
- A non-production environment with test accounts and synthetic data.

## Procedure
1. **Set scope and rules of engagement.** Record in-scope components, out-of-scope systems (including the model provider's infrastructure), allowed techniques, data handling rules, and stop conditions: halt and escalate immediately if testing exposes real user data, real credentials, or causes real-world side effects. Test in staging with synthetic data.
2. **Build a threat model from the app's real risks.** Ask what would actually hurt users or the business: disclosure of the system prompt or other users' data, unauthorized tool actions, policy-violating output in your domain, brand-damaging statements, cost abuse. Rank by impact and likelihood. This keeps effort on relevant failures rather than generic stunts.
3. **Map attack categories to risks.** Use broad technique families as coverage dimensions, for example: role-play and persona framing, instruction override, multi-turn gradual escalation, obfuscation and encoding, language switching, payload splitting across turns, indirect injection through documents or tool results, and abuse of tools or long context. Public taxonomies such as the OWASP Top 10 for LLM Applications and MITRE ATLAS help check coverage.
4. **Design test cases around canary objectives.** Instead of trying to elicit genuinely dangerous content, define harmless but policy-violating targets that prove a control failed: reveal a planted secret string in the system prompt, output a forbidden marker phrase, call a sandboxed tool the user should not reach, or read a synthetic record belonging to another test account. Each case records: id, risk, technique family, turns, canary objective, and expected safe behaviour. Write cases for your own application; do not collect or reuse working jailbreak prompts targeting third-party products.
5. **Execute systematically.** Run each case several times, because outputs are stochastic; record the success rate rather than a single pass or fail. Log full transcripts in the test environment. Combine manual creative testing with automated variation of your own seed cases.
6. **Score findings consistently.** Severity = impact (data exposure, unauthorized action, harmful output, nuisance) x reproducibility (rate across runs) x effort (single turn versus long setup). Use a fixed scale such as critical, high, medium, low with written definitions.
7. **Remediate in layers.** Typical fixes: least-privilege tools and server-side authorization, confirmation for side-effecting actions, separating untrusted content from instructions, input and output classifiers, and system prompt hardening. Prompt changes alone are rarely sufficient for critical findings.
8. **Retest and add regressions.** Re-run every finding after the fix and add all cases to a regression suite that runs on each model, prompt, or tool change. Track over-refusal on benign requests as well, since hardening can break legitimate use.
9. **Report responsibly.** Share detailed transcripts only with the owning team; summarize techniques at the category level in wider reports.

## Expected output
```markdown
## Red-team report: <application> (<environment>, <dates>)
Authorization: <reference>; testers: <names>; out of scope: <list>
| Risk | Technique families tested | Cases | Findings |
|---|---|---|---|
| Cross-account data access | indirect injection, tool abuse | 12 | 1 high |

### Finding RT-03 (High)
Canary objective: read synthetic record of test account B from account A
Technique family: indirect injection via uploaded document
Success rate: 3/10 runs
Root cause: retrieval tool not scoped to caller's account
Remediation: enforce account filter server-side; retest passed 0/20
Regression case added: yes
Over-refusal check: <benign pass rate before/after>
```

## Constraints and limitations
- Only for systems you own or are authorized in writing to test; respect the model provider's usage policies.
- Uses canary objectives; never generate or retain genuinely harmful instructions or real personal data as test artifacts.
- A clean result shows the tested cases failed, not that the application is secure.
- Safety findings with legal or regulatory impact need review by the organization's security and legal owners.

## Examples
A customer-support bot was tested for system prompt disclosure using a planted canary string. Persona and translation framings each leaked the canary in a minority of runs. The team moved confidential routing rules out of the prompt into server-side logic, added an output filter for the canary pattern as a detector, and kept the cases in the regression suite; retesting showed no leaks across repeated runs and no change in benign-task pass rate.
