---
name: trend-signal-detection
description: Assesses whether an emerging trend reflects real adoption or mostly attention. Collects signals across independent indicator families (usage, spend, hiring, supply-side investment, standards and regulation, switching behaviour, attention), weights behavioural evidence above talk, places the trend on an adoption curve with stated uncertainty, and defines watch indicators. Use for trend reports, technology radars, horizon scanning, and investment theses.
---

# Trend Signal Detection

## When to use

Use this skill when someone asks whether a technology, behaviour, business model, or policy direction is "taking off", when a trend appears in many headlines and you need to know how much is substance, or when building watch indicators for a strategy. It works for consumer, enterprise, technical, and regulatory trends.

It does not forecast precise numbers or timing, and it is not suited to a trend with no observable footprint at all; in that case, record it as a speculative weak signal and define what would make it observable.

## Inputs

- The trend, stated precisely (who is adopting what, for which purpose, where).
- The decision the assessment informs and its time horizon.
- Any data the user has (internal usage, sales pipeline, customer requests).
- Access to public sources for the indicator families below.

## Procedure

1. **State the trend as a testable claim.** "Mid-size manufacturers in the EU are deploying private 5G networks in production sites" is testable; "private 5G is hot" is not.
2. **Collect signals from each indicator family.** Aim for at least one signal per family and record source and date:
   - Usage and behaviour: active usage data, downloads with retention, transaction volumes, public deployment announcements naming customers.
   - Spend: customer budgets, vendor revenue disclosures, public procurement awards.
   - Hiring and skills: job postings requiring the skill, by adopter companies rather than vendors.
   - Supply-side investment: funding rounds, product launches, incumbents' roadmap commitments, M&A.
   - Standards, regulation, and infrastructure: standards bodies, interoperability specs, regulatory guidance, complementary infrastructure.
   - Switching and displacement: evidence of customers replacing an incumbent approach, and of incumbents responding.
   - Attention: media coverage, search interest, conference agendas, social discussion.
3. **Separate adoption from attention.** Classify each signal as behaviour (someone paid, deployed, hired, switched) or talk (someone wrote, funded, predicted, announced). Hype shows strong talk with weak behaviour; real adoption shows behaviour from buyers who are not vendors.
4. **Check independence and quality.** Several signals tracing to one vendor's press campaign count once. Note proxy weaknesses: stars and downloads can be inflated, search interest reflects curiosity, job posts may be aspirational.
5. **Look for disconfirming evidence.** Search for failed pilots, abandoned deployments, declining usage, critical analyses, and regulatory obstacles.
6. **Place the trend.** Describe its position using an adoption-curve vocabulary (emerging, early adopters, early majority, mainstream, declining) and, if useful, note whether attention is running ahead of adoption, as frameworks such as the Gartner Hype Cycle describe. State confidence and the main uncertainty.
7. **Define watch indicators.** Pick three to five indicators with thresholds that would change the assessment, such as "two or more top-ten industry incumbents announce production deployments" or "job postings at non-vendor firms double year on year".
8. **Score summary.** Rate adoption evidence and attention separately on a simple scale (low, medium, high) and show the gap.

## Expected output

```markdown
**Trend (testable claim):** ...
**Horizon and decision:** ...

| Indicator family | Signal | Behaviour or talk | Source (date) | Strength | Notes |
|---|---|---|---|---|---|

**Disconfirming evidence:** ...
**Adoption evidence:** <low/medium/high> · **Attention:** <low/medium/high> · **Gap:** <attention ahead / aligned / adoption ahead>
**Position:** <stage> · **Confidence:** <level> because ...

| Watch indicator | Current reading | Threshold to revise | Where to check |
```

## Constraints and limitations

- Trend assessment is structured judgement; present it as such, with sources.
- Public signals over-represent vendors and enthusiasts; buyer-side evidence is scarcer and more valuable.
- Lagging indicators (revenue, regulation) confirm trends late; leading indicators (hiring, pilots) are noisier.
- Do not fabricate data points or extrapolate growth rates from two observations.

## Examples

**Trend:** "Retail banks are using generative AI in customer-facing chat."
Signals: many vendor announcements and conference talks (talk, high); several banks' annual reports describe internal pilots for staff, fewer describe customer-facing production use (behaviour, medium for internal, low for customer-facing); regulators publish guidance on model risk (infrastructure, medium); job postings for related roles at banks rising (behaviour, medium). Disconfirming: public reports of chatbot errors leading to restricted rollouts.
Assessment: attention high, customer-facing adoption low-to-medium, internal use further ahead. Watch: number of banks disclosing customer-facing production deployment in annual reports.
