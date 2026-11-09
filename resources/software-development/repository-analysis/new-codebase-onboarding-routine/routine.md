# New Codebase Onboarding Routine

## Objective
Within the first working week on an unfamiliar repository, build a working mental model you can act on: the system builds and runs locally, you can sketch its architecture and have a teammate confirm it, you have traced one real request or job from entry point to storage and back, and you have merged one small change through the team's full delivery process. Along the way you produce onboarding notes that fix at least one gap in the existing docs for the next person. For a fast automated survey of the repository to accelerate day 2, `repository-intelligence-agent` can produce a cited brief.

## Trigger
Run it when you join a team, transfer to a different service, inherit a codebase, or start contributing to an open-source project. It is a plan you follow and adjust, not an automated process, and it assumes about half of each day is available for onboarding.

## Prerequisites
- Repository access and the ability to create branches and open pull requests.
- Development credentials for non-production environments only; production access is not needed and should not be requested for onboarding.
- A named onboarding buddy who can answer questions and review your first change.
- A starter task agreed with your lead, ideally small, low-risk and user-visible (a bug fix, a missing validation, a log improvement).

## Inputs
- Required: repository URL, README and contribution guide, the team's issue tracker, the starter task.
- Optional: architecture docs, ADRs, runbooks, dashboards, recent incident postmortems, the onboarding notes of the previous joiner.

## Steps
1. **Day 1 — get it running.** Follow the README exactly and record every deviation (missing tool versions, undocumented environment variables, failing seed scripts). Build, run the test suite, and start the app locally. Success criterion: you can hit one endpoint or open one screen and see your own log line. If setup blocks you for more than about two hours, ask your buddy instead of pushing alone.
2. **Day 1 — orient in the tree.** Identify the language and framework versions, the dependency manifest, the entry points (main functions, route registration, job schedulers, CLI commands), configuration loading, and where tests live. Write a one-paragraph description of what each top-level directory holds.
3. **Day 2 — sketch the architecture.** Draw the components (services, databases, queues, caches, external APIs) and arrows between them. Mark each arrow as synchronous or asynchronous. Use the dependency manifest, docker-compose or infrastructure files, and config to find the real dependencies rather than relying on the docs alone.
4. **Day 2 — find where change happens.** Use git history to see which areas change most and who changes them, for example `git log --since="6 months ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -30` and `git shortlog -sn --since="6 months ago" -- <dir>`. The `git-history-forensics` skill explains how to interpret churn and ownership. High-churn files are where your work will likely land and where bugs cluster.
5. **Day 2 — validate the sketch.** Spend 30 minutes with your buddy walking your diagram. Ask what is wrong, what is missing, and which parts are being retired. Record the corrections.
6. **Day 3 — trace one request end to end.** Pick a core user action (place an order, log in, run the nightly import). Follow it from the entry point through middleware, business logic, data access, and any asynchronous handoff, writing down each file and function. Set breakpoints or add temporary logs locally to confirm the path; reading alone tends to miss middleware and framework magic. When a section is dense, use `explain-unfamiliar-code-prompt` on that excerpt.
7. **Day 3 — learn the safety nets.** Find how the team tests (unit, integration, end to end), how CI is configured, how deploys happen, what feature flags exist, and where dashboards and alerts live. Read one or two recent postmortems to learn the system's known failure modes.
8. **Day 4 — make the starter change.** Write a failing test first if feasible, implement the change, and follow the team's conventions for commits, branch names and PR descriptions. Keep the diff small.
9. **Day 4-5 — ship it through the real process.** Open the PR, respond to review, watch CI, and, where your team allows newcomers to, observe or perform the deploy with your buddy. Record anything in the process that surprised you.
10. **Day 5 — write onboarding notes and improve the docs.** Summarise the architecture sketch, the traced request, the glossary of domain terms you had to learn, setup fixes, and open questions. Turn the setup deviations from step 1 into a README pull request (the `readme-authoring` skill helps structure it).
11. **Day 5 — agree next steps.** Review your notes with your lead and agree on the next two or three tasks that deepen your knowledge of a high-churn area.

## Decision points
- If the project cannot be built locally by the end of day 1, escalate; a broken setup is a team problem worth fixing, and your notes are the evidence.
- If the codebase is very large (multiple services or a monorepo), narrow steps 3-6 to the service that owns your starter task and treat the rest as boxes on the diagram.
- If documentation and code disagree, trust the code and confirmed behaviour, and note the discrepancy for the docs PR.
- If the starter task turns out to be risky (touches payments, auth or data deletion), ask for a different task rather than shipping a high-risk first change.
- If a script or Makefile target looks destructive (drops databases, resets shared environments), confirm with your buddy before running it.

## Expected output
An onboarding notes document containing: setup steps that actually worked, a directory map, a validated architecture diagram, one traced request with file and function references, a domain glossary, a list of high-churn areas and their owners, open questions, plus one merged starter PR and one documentation PR.

## Validation checklist
- [ ] The app builds, tests run, and a local request succeeds from a clean checkout following the updated README.
- [ ] The architecture sketch was reviewed by a teammate and corrections were applied.
- [ ] The traced request lists concrete files and functions and was confirmed by running it.
- [ ] The starter change was merged through the normal review and CI process.
- [ ] A documentation improvement PR was opened from the setup deviations found.
- [ ] Open questions are written down with the person likely to answer each.

## Human approval
Your lead approves the starter task and any change to scope or schedule. Your buddy or a code owner reviews and approves the starter PR and documentation PR; you do not self-merge. Any access beyond development environments, any deploy you perform, and running scripts that modify shared environments require explicit approval from the team. If you use an assistant during onboarding, it should work read-only on your local clone and must not push, merge or run commands against shared systems without your explicit instruction.
