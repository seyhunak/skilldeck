# Weekly Metrics Review Routine

## Objective
Give a team a predictable, roughly thirty-minute weekly review of its core metrics that ends with decisions and owners rather than a recitation of numbers. Each week produces a short written summary: which metrics are within their expected range, which moved beyond it and what is known about why, which data issues affected the numbers, and which follow-ups are open with an owner and due date. Over time the running log becomes the team's memory of what moved, why, and what was done about it.

## Trigger
Run once a week at a fixed time after the previous week's data has fully landed (for most pipelines, at least one full day after week end; set this from your known pipeline latency). Also run an extra abbreviated pass after a launch, pricing change, or incident when leadership expects a read on impact. A person, usually an analyst or the metric owner, prepares and leads the review; an assistant may draft the pre-read but does not publish it.

## Prerequisites
- A fixed metric list of roughly five to fifteen metrics, each with a written definition (see `metric-definition`), an owner, and a direction of good.
- A dashboard or query set that reports each metric at weekly grain with at least a year of history where available.
- An expected range per metric: for example the trailing eight-week range, or a band around a forecast or target. Record which method each metric uses.
- An events calendar: launches, campaigns, outages, holidays, pricing changes, tracking changes.
- The running review log from previous weeks.

## Inputs
- This week's values and the comparison values: prior week, same week last year (for seasonal businesses), and the target or forecast.
- Pipeline freshness and completeness status for the sources behind each metric.
- Notes from metric owners on known events.
- Open action items from the log.

## Steps
1. **Check data health before reading any number.** Confirm each source loaded through the end of the week, row counts are in their normal range, and no tracking or definition change shipped. Mark any metric with incomplete or suspect data as "data issue" and keep it out of the performance discussion; route it to `data-quality-investigation-agent` or the pipeline owner.
2. **Lay out the scorecard.** For each metric: current value, change versus prior week, change versus the same week last year or a seasonal baseline, distance from target, and whether it is inside its expected range. Show absolute and percentage change together. Use a consistent layout every week so readers find things in the same place.
3. **Classify each metric.** Inside range and on track: no discussion. Outside range: candidate for discussion. Persistent drift (moving in the same direction for several weeks while still in range): note as a trend to watch. Several consecutive weeks in one direction often matter more than one large week.
4. **Do a first-pass decomposition for each flagged metric.** Before the meeting, split the movement by the two or three most likely dimensions (platform, region, acquisition channel, new versus returning) and by components if the metric is a ratio (numerator versus denominator) or a product (traffic times conversion times order value). Check the events calendar. Write one line: where the movement is concentrated and the leading explanation, labeled as confirmed or hypothesis.
5. **Write the pre-read.** Lead with the two or three things that need attention, then the scorecard, then data issues. `insight-narrative-prompt` can help draft the headline section from the scorecard. Circulate it ahead of the meeting so the meeting is for discussion, not reading.
6. **Run the review.** Spend time only on flagged metrics and open actions. For each flagged metric decide: explained and no action, explained and action needed, or unexplained and needs investigation. Unexplained movements that are large or affect a key metric go to a deeper investigation with `metric-anomaly-investigation-agent`.
7. **Record outcomes in the log.** For each flagged item, write the explanation status, the owner, the next step, and a due date. Close actions that are done, and carry forward the rest with their age.
8. **Monthly, review the review.** Once a month, check whether expected ranges are still sensible, whether any metric has never prompted a decision (candidate for removal), and whether recurring explanations point to a missing segment or dashboard view.

## Decision points
- **Data health check fails for a metric**: report it as unavailable or provisional; do not interpret it. If it is a top-line metric, notify consumers that this week's figure will be restated.
- **Movement is outside range but coincides with a known event** (holiday, outage, campaign): record the explanation and move on unless the size is out of proportion to the event.
- **Movement is concentrated in one segment**: assign the segment's owner rather than the metric's overall owner.
- **Ratio metric moved because the denominator changed** (for example a traffic surge from a low-intent source): say so explicitly; it changes who should act.
- **Same metric flagged three weeks in a row without an explanation**: escalate to a dedicated investigation with a deadline.
- **A metric definition or tracking change is needed**: do not change it mid-review; record the request and route it to the metric owner, and annotate the history when it ships.

## Expected output
A weekly entry in the review log containing: data health status per source; the scorecard with values, comparisons, and range status; flagged metrics with decomposition summary and explanation status (confirmed, hypothesis, unexplained); decisions taken; action items with owner, due date, and age; and any proposed changes to metrics or ranges for the monthly check.

## Validation checklist
- [ ] Data freshness and completeness were checked before interpretation.
- [ ] Every metric was compared with both a short-term and a seasonal or target baseline.
- [ ] Each flagged movement has a concentration finding and is labeled confirmed, hypothesis, or unexplained.
- [ ] Every action item has a single owner and a due date.
- [ ] Open actions from previous weeks were reviewed and closed or carried forward.
- [ ] Explanations are worded as association unless an experiment or direct evidence confirms cause.

## Human approval
The review owner approves the pre-read before it circulates and the summary before it is shared beyond the team, especially when it includes provisional figures. Changes to metric definitions, expected-range methods, or targets require approval from the metric owner and are recorded in the log with an effective date. Starting a cross-team investigation or escalating to leadership is the review owner's decision, not the assistant's.
