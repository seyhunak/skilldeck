# Incident Postmortem Routine

## Objective
Turn a resolved incident into durable learning: an accurate timeline, a clear statement of impact, an analysis of the contributing factors that made the incident possible and slowed recovery, and a small set of owned, verifiable action items that are tracked to completion. The review is blameless: it assumes people acted reasonably given what they knew and the tools they had, and it looks for the system conditions that allowed the failure. Diagnosis during the incident itself belongs to `production-incident-debugger-agent`; this routine starts once service is restored.

## Trigger
Run it after any incident that meets your organisation's postmortem criteria. If none exist, a reasonable starting heuristic is: any customer-visible outage or data issue, any breach of an SLO error budget threshold, any security event, any incident needing a rollback of a release, or a near miss that would have been serious. Start the draft within two working days while memory is fresh, and hold the review meeting within about a week. The routine is a facilitation guide for people; it does not run itself.

## Prerequisites
- Service restored and the incident formally closed or downgraded.
- A named facilitator who was not the primary responder, if possible, to keep the discussion neutral.
- Access to the incident channel history, alerts, dashboards, deploy logs, tickets and any customer reports.
- Agreement from leadership that the review is blameless and that findings will not be used for individual performance evaluation.

## Inputs
- Required: incident channel or call notes, alert and paging history, deploy and config change logs for the window, metrics and logs around detection and recovery.
- Optional: customer support tickets, status page updates, previous postmortems for the same service, runbooks used, on-call handover notes.

## Steps
1. **Collect evidence before opinions.** Export the incident channel, alerts, graphs and change logs into the draft. Note gaps in evidence (missing logs, unrecorded manual actions) as findings in their own right.
2. **Build the timeline.** In UTC, list events from the triggering change or condition through detection, escalation, diagnosis, mitigation and full recovery. Each entry: timestamp, what happened, source of evidence. Mark the key intervals: time to detect, time to engage, time to mitigate, time to resolve. Keep descriptions factual ("deploy of v3.2 began") rather than evaluative.
3. **Quantify impact.** Duration, users or requests affected, error rates, data affected, financial or contractual consequences if known, and error budget consumed. Use measured values and state how they were derived; write "unknown" rather than estimate silently.
4. **Interview responders.** Short one-to-one conversations before the group meeting. Ask what they saw, what they expected, what they tried, and what made the right action hard. Avoid "why did you" phrasing; ask "what made that look like the right step at the time?"
5. **Analyse contributing factors.** Use more than one lens. Ask "how did this happen?" repeatedly across technical, process and organisational dimensions, accepting that there are usually several causes rather than one root. Separate factors into: what triggered it, what allowed it to spread or grow, what delayed detection, and what delayed recovery. "Human error" is never an endpoint; ask what made the error easy and its consequences large.
6. **Record what went well.** Alerts that fired correctly, runbooks that worked, good communication. These are as important to preserve as gaps are to fix.
7. **Hold the review meeting.** Typically 45-60 minutes with responders, service owners and a facilitator. Walk the timeline, validate factors, and agree on action items. The facilitator redirects any blame toward conditions and tools.
8. **Define action items.** Each one: a specific change, the factor it addresses, an owner (a person, not a team), a priority, a due date, and how completion will be verified. Prefer fewer, high-leverage items: preventive (stop recurrence), detective (catch it sooner), and mitigative (reduce blast radius or time to recover). Heuristic: three to seven actions; more usually means none get done.
9. **Review and publish.** Have the document reviewed for accuracy by responders and for sensitive content (personal data, security details, customer names). Share at the agreed visibility level.
10. **Follow up.** Put action items in the team's tracker, and schedule a check at the due dates. Re-open the postmortem if actions slip without a decision to drop them.

## Decision points
- If the incident involved a security breach or personal data exposure, involve the security and legal or privacy owners before writing details, and restrict the document's distribution.
- If evidence is missing for a key interval, record it as a finding and add an observability action item rather than filling the gap with recollection alone.
- If the same contributing factor appears in a previous postmortem, escalate the related action item's priority and note the repeat explicitly.
- If an action item has no willing owner, it is not an action item; either assign it with the manager's agreement or record it as an accepted risk.
- If discussion turns to an individual's fault, the facilitator pauses and reframes to the system condition.

## Expected output
A postmortem document with: summary (three sentences), impact, timeline table (UTC time, event, evidence), detection and recovery intervals, contributing factors grouped by trigger, spread, detection and recovery, what went well, lessons, and an action item table:

```text
ID  Action                                 Addresses           Type        Owner   Priority  Due     Verified by
A1  Add canary stage for config deploys    trigger, spread     preventive  <name>  P1        <date>  canary blocks bad config in drill
A2  Alert on queue age > 5 min             detection delay     detective   <name>  P2        <date>  alert fires in staging test
```

## Validation checklist
- [ ] Timeline entries are in UTC and each cites a source of evidence.
- [ ] Impact uses measured figures or explicitly says "unknown".
- [ ] No sentence assigns blame to an individual; factors describe conditions, tools and processes.
- [ ] Every action item has one named owner, a due date and a verification method.
- [ ] What went well is recorded alongside the gaps.
- [ ] Sensitive data was reviewed and redacted before distribution.

## Human approval
The service owner or engineering manager approves the final document, the action items and their priorities, and the distribution level. Security or privacy owners must approve any content describing vulnerabilities or personal data exposure, and any external customer communication requires the agreed approver. Assistants may draft timelines and summaries from provided evidence, but must not publish the postmortem, file tickets in someone's name, or contact customers.
