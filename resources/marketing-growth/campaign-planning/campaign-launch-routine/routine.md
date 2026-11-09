# Campaign Launch Routine

## Objective
Launch a marketing campaign without the avoidable failures that waste the first days of budget: broken or missing tracking, wrong audiences or geographies, landing pages that do not match the ads, unapproved claims, emails sent to the wrong list, and nobody watching the numbers. The routine sequences pre-launch checks, a staged go-live, and first-week monitoring, with a named human approving each gate. It covers paid media, email, and organic social components of a campaign; skip the sections that do not apply.

## Trigger
Start the routine when a campaign brief is approved and assets are in production, ideally at least one to two weeks before the planned launch date. Run the launch-day and first-week sections on the go-live date. The routine is a human-run checklist; an AI agent may help prepare checklists or review exports, but it does not operate ad platforms, email tools, or social accounts.

## Prerequisites
- An approved campaign brief: objective, primary KPI with target, audiences, channels, budget and pacing, flight dates, offer, and landing pages.
- Named owners: campaign owner (accountable), channel operators, analytics owner, copy and creative approver, and legal or compliance reviewer where the industry or claims require it.
- Access for operators to the ad platforms, email service provider, and analytics tools (the routine owner does not need write access).
- A UTM naming convention and a shared campaign tracker.
- Baseline metrics from a comparable prior campaign or period, for early-warning thresholds.

## Inputs
- Final creative and copy for every placement and email.
- Audience definitions, exclusion lists, and email segments with consent status.
- Landing page URLs (staging and production).
- Conversion definitions and where they are recorded (analytics, ad platforms, CRM).
- Budget by channel and day, with bid strategies.

## Steps
1. **Lock the brief and measurement plan (T-10 to T-7 days).** Confirm the primary KPI, how it is measured, the source of truth for each metric, and what success and failure look like. Use the `marketing-attribution-analysis` skill to agree in advance how cross-channel credit will be reported, so the readout is not argued after the fact. Define early-warning thresholds, for example spend pacing more than 25% off plan or cost per conversion above twice the target after a minimum spend; these are illustrative and should be set from your own baselines.
2. **Build and verify tracking (T-7 to T-3).** Generate UTM-tagged URLs for every ad, email link, and social link from the naming convention. Verify conversion events fire once per conversion on the production landing page, in analytics, in each ad platform, and in the CRM, using a test conversion clearly marked as test. Check consent banners do not block required tags in an unexpected way and that thank-you pages cannot be reached without converting.
3. **Review copy and creative (T-7 to T-3).** Check every asset against the approved messaging and claims; run a voice review with `brand-voice-guardian-agent` if needed. Verify offer details (prices, dates, discount terms) match the landing page exactly. Confirm character limits, image specifications, and ad policies against each platform's current documentation, since these change; do not rely on remembered limits. Route regulated or comparative claims to legal or compliance.
4. **QA landing pages (T-5 to T-2).** Load each page on mobile and desktop, check message match with the ads, test forms end to end (including where submissions go and confirmation emails), check load speed, check that links and promo codes work, and confirm the page is live on the production URL used in the ads.
5. **Configure and review channel setup (T-3 to T-1).** Operators build campaigns in a paused or draft state. A second person reviews: geography, language, schedule, audience inclusions and exclusions (existing customers, employees, recent converters), budgets and daily caps, bid strategies, placements, frequency caps, and the destination URL for every ad. For email: segment counts versus expectations, suppression of unsubscribed and bounced contacts, sender name and address, subject lines, links, personalization fallbacks, and a seed-list test send to internal addresses.
6. **Hold the go/no-go review (T-1).** Walk through the checklist with the campaign owner. Every gate is marked pass, fail, or waived with a named approver for any waiver. The campaign owner gives explicit approval to launch.
7. **Go live in stages (launch day).** Activate one channel or a small budget share first where practical, confirm impressions, clicks, and conversions begin appearing in platform and analytics reports within the expected delay, then activate the rest. Send email to the approved segment only after the paid and landing components are confirmed working, unless the plan says otherwise.
8. **Monitor the first 72 hours.** Check at least twice daily: spend pacing, delivery issues and disapprovals, CTR and conversion rate versus baseline, landing page errors, email bounce, complaint, and unsubscribe rates, and whether conversions match across platform, analytics, and CRM within expected gaps. Log each check in the tracker.
9. **Run the first-week review (day 5 to 7).** Compare early results with targets and thresholds, fix confirmed problems, and decide on early optimizations (pausing clearly failing ads, rebalancing budget). Avoid large changes before platforms have enough data, unless something is broken.
10. **Hand over for ongoing reporting.** Record what was launched, all deviations and waivers, and open issues, and hand over to the analyst or `campaign-performance-analyst-agent` for the mid-flight and final readouts.

## Decision points
- If any conversion event fails verification, do not launch paid media to that page until it is fixed; spending without measurement wastes the learning as well as the money.
- If a claim lacks substantiation or legal approval, remove or replace it; do not launch with it pending.
- If email segment counts differ from expectations by more than a small margin, stop and investigate before sending; it usually means a filter or consent error.
- If ads are disapproved at launch, fix and resubmit only after reading the specific policy cited; do not try workarounds.
- If an early-warning threshold is breached in the first 72 hours, the campaign owner decides between pausing, fixing, or continuing, and records the decision.
- If a landing page or form breaks after launch, pause traffic to it immediately and notify the campaign owner.

## Expected output
A completed launch checklist with pass, fail, or waived status and approver for every gate; a tracking verification record; a launch log with timestamps of each activation; a 72-hour monitoring log; a first-week review note with decisions taken; and a handover note listing deviations and open issues.

## Validation checklist
- [ ] The primary KPI, source of truth, and early-warning thresholds were agreed before launch.
- [ ] Every conversion event was verified end to end with a marked test conversion.
- [ ] Every link carries UTM parameters that follow the naming convention.
- [ ] All claims and offer details were checked against approved messaging and the landing page, with legal sign-off where required.
- [ ] Platform limits and policies were confirmed in current platform documentation, not from memory.
- [ ] A second person reviewed audience, budget, geography, and exclusion settings before activation.
- [ ] The campaign owner gave explicit go-live approval, and any waived gate names its approver.
- [ ] First 72 hours of monitoring were logged.

## Human approval
The campaign owner must explicitly approve go-live, every budget increase above the approved plan, and any waiver of a failed gate. Email sends to customer lists require the campaign owner's approval of the final segment and content, and confirmation that consent and unsubscribe handling meet the organization's compliance requirements. Claims in regulated categories or comparative claims about competitors require legal or compliance approval before launch. No one following this routine, and no AI assistant supporting it, should activate campaigns, send email, publish posts, or change budgets without that approval being recorded.
