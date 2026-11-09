---
name: security-log-analysis
description: Analyses authentication, identity provider, cloud audit, web server, and endpoint logs for anomalies and indicators of compromise. Normalises sources to UTC, baselines normal behaviour, runs hypothesis-driven hunts (password spraying, impossible travel, MFA fatigue, privilege escalation, log tampering), and returns an evidence-referenced timeline with confidence levels. Use during investigations or periodic threat hunts.
---

# Security Log Analysis

## When to use

Load this skill when an analyst or agent must answer a question from logs the organisation owns: "Was this account compromised?", "What did this key do after it leaked?", "Is anyone spraying passwords at our VPN?", or "Build the timeline for this incident." It supports incident response, threat hunting, and access investigations.

Do not use it for performance or availability debugging (use `metric-anomaly-investigation-agent` or observability tooling) or for analysing logs from systems the user is not authorised to access. For coordinating the overall incident, use `incident-response-coordinator-agent`.

## Inputs

- **Question or hypothesis** — what you are trying to prove or disprove. Required; analysis without a question drifts.
- **Log sources** — exports or query access for the relevant sources, with time range and time zone. Required.
- **Context** — accounts, hosts, IP addresses, or keys of interest; known-good IP ranges (offices, VPN egress); normal working hours and locations. Optional but sharply reduces false positives.

Work on copies; never alter original logs.

## Procedure

1. **Inventory and normalise.** For each source record system, time range, time zone, and retention. Convert all timestamps to UTC with ISO 8601 format. Map fields to a common set: time, actor (user, key, role), source IP, user agent or device, action, target, result. Note gaps: missing hours, disabled sources, or sampling.
2. **Baseline.** For the actors in question, establish normal: usual countries and ASNs, devices, login hours, typical actions and volumes over the previous 30 days if available. Anomalies are deviations from this baseline, not just "unusual-looking" events.
3. **Run targeted hunts.** Select those relevant to the question:
   - **Password spraying** — many accounts each with a few failures from the same IP or ASN within a short window (Windows Security event 4625, Linux `Failed password` in `auth.log` or `secure`, identity provider failure events).
   - **Brute force and credential stuffing** — many failures against one account, or high-volume failures across many accounts with diverse IPs, followed by a success.
   - **Impossible or improbable travel** — successive successful logins for one account from locations too far apart for the elapsed time; check for VPN or cloud egress before concluding.
   - **MFA fatigue** — repeated MFA push denials or timeouts followed by an approval.
   - **New persistence or privilege** — new users (4720), group membership changes (4728, 4732, 4756), special privileges at logon (4672), new cloud access keys (`CreateAccessKey`), policy attachments (`AttachUserPolicy`, `PutRolePolicy`), new OAuth app consents, new mailbox forwarding rules.
   - **Defence evasion** — audit log cleared (1102), `StopLogging` or `DeleteTrail`, disabled security agents, guardrail changes.
   - **Data access anomalies** — unusual volume of object reads (`GetObject`), bulk exports, downloads outside working hours.
   - **Web attack traces** — repeated 4xx/5xx bursts from one source, requests to admin paths, unusual user agents, long query strings; correlate with application errors.
4. **Pivot.** From each suspicious event pivot on actor, IP, session ID, and user agent across all sources to build the chain: initial access, actions, persistence, and exit. Record each query or filter used so others can rerun it.
5. **Map to ATT&CK.** Where useful, label confirmed behaviours with MITRE ATT&CK technique IDs (for example, T1110.003 Password Spraying, T1078 Valid Accounts) to communicate with other responders. Do not force-fit.
6. **Assign confidence.** For each conclusion: *High* (multiple independent sources agree), *Medium* (one source, consistent with context), *Low* (plausible, unconfirmed). State alternative explanations explicitly, such as travel, a new VPN, or an automated job.
7. **Extract indicators.** List IPs, domains, user agents, file hashes, and account names observed in malicious activity, with first and last seen. Mark which are high-signal and which are shared infrastructure (for example, a cloud provider IP) and unsafe to block broadly.

## Expected output

1. **Answer** to the question in three sentences with overall confidence.
2. **Timeline (UTC):**

| Time | Source | Actor | Source IP / device | Action | Result | Evidence ref | Assessment |
|---|---|---|---|---|---|---|---|

3. **Findings** with confidence and alternative explanations.
4. **Indicators** table (type, value, first seen, last seen, context, blocking safety).
5. **Queries used** and **coverage gaps** (missing sources, retention limits).

## Constraints and limitations

- Absence of evidence in logs is not evidence of absence; state retention and coverage limits.
- IP geolocation is approximate; VPNs, proxies, and mobile carriers distort location.
- Never print credentials, session tokens, or API keys that appear in log lines; mask them and recommend rotation.
- Minimise personal data in outputs. This is not professional forensic or legal advice; conclusions used for disciplinary, legal, or notification decisions need a qualified investigator.

## Examples

Question: "Was `j.doe` compromised on 3 November?"

Findings: 41 failed logins across 37 different accounts from one hosting-provider IP between 02:10 and 02:25 UTC (spray pattern, High); one success for `j.doe` from that IP at 02:24 after two failures; MFA push denied twice, approved at 02:27 (MFA fatigue, High); at 02:31 a mailbox rule forwarding invoices to an external address was created from the same session (persistence, High). Alternative explanations considered: user travel (rejected, the user's device logged in from the usual office at 08:55). Recommended to the incident coordinator: revoke sessions, reset credentials, remove the rule, and review other accounts targeted by the spray for successes.
