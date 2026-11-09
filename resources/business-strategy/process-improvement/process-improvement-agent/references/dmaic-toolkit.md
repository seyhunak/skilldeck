# DMAIC toolkit reference

## Tool selection by problem type
| Phase | Flow problems (delay, backlog, handoffs) | Variation/defect problems |
|---|---|---|
| Define | SIPOC, charter | SIPOC, charter, CTQ tree |
| Measure | Value stream map, lead time, WIP, throughput | Measurement system check, defect data, control chart, capability |
| Analyze | Wait-time Pareto, bottleneck analysis, Little's Law | Fishbone, Pareto, stratification, hypothesis tests, regression |
| Improve | Remove batching, pull, WIP limits, level loading | Poka-yoke, standardisation, design of experiments |
| Control | Visual management, WIP limits, standard work | Control charts, reaction plans, audits |

## Key formulas
- **Little's Law:** average lead time = average WIP / average throughput (for a stable system). Useful to show that cutting WIP cuts lead time.
- **Process cycle efficiency** = value-added time / total lead time.
- **First-pass yield** = units completed correctly without rework / units entering.
- **Rolled throughput yield** = product of first-pass yields of each step.
- **DPMO** = defects / (units x opportunities per unit) x 1,000,000. Define "opportunity" carefully and keep it fixed.
- **Cp** = (USL - LSL) / 6σ; **Cpk** = min(USL - μ, μ - LSL) / 3σ. Valid only for a stable, roughly normal process.

## Control chart choice
- Continuous data, individual measurements: I-MR chart.
- Continuous data in subgroups: X-bar and R (or S) chart.
- Proportion defective: p-chart. Count of defects: c-chart or u-chart.
- Common special-cause signals: a point beyond the 3σ limits; a run of several consecutive points on one side of the centre line (rule sets differ — state which you use).

## Measurement system check (light version)
Before trusting defect data, check whether two people classify the same sample of items the same way. Low agreement means the Measure phase must fix definitions first.

## Root-cause verification statuses
- **Verified:** data test supports the cause and the mechanism is understood.
- **Plausible:** consistent with evidence but not tested.
- **Refuted:** data contradicts the hypothesis.
