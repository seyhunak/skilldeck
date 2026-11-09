# Skilldeck content quality report

Resources scored: **250** · Flagged below 24/36: **12**

Heuristic scores (0-4 per criterion) highlight resources that need human review. They complement, not replace, the maintainer review in docs/REVIEW_POLICY.md.

## Averages by type

| Type | Count | Avg score | Min | Avg words |
|---|---:|---:|---:|---:|
| agent | 100 | 31.3 | 29 | 1254 |
| prompt | 30 | 25.9 | 24 | 778 |
| routine | 20 | 24.5 | 21 | 1001 |
| skill | 100 | 28.3 | 23 | 770 |

## Flagged for review

- `llm-feature-launch-routine` (routine) — 21/36; weakest: usefulness, output_clarity, error_handling
- `model-upgrade-regression-routine` (routine) — 21/36; weakest: usefulness, output_clarity, error_handling
- `rag-pipeline-evaluation-routine` (routine) — 21/36; weakest: usefulness, output_clarity, error_handling
- `annual-strategic-planning-routine` (routine) — 23/36; weakest: usefulness, output_clarity, error_handling
- `quarterly-business-review-routine` (routine) — 23/36; weakest: usefulness, output_clarity, error_handling
- `weekly-metrics-review-routine` (routine) — 22/36; weakest: usefulness, output_clarity, error_handling
- `credit-application-review-routine` (routine) — 23/36; weakest: usefulness, output_clarity, safety
- `monthly-seo-health-check-routine` (routine) — 23/36; weakest: usefulness, output_clarity
- `feature-launch-routine` (routine) — 22/36; weakest: usefulness, output_clarity, error_handling
- `product-discovery-sprint-routine` (routine) — 22/36; weakest: usefulness, output_clarity, error_handling
- `security-policy-writing` (skill) — 23/36; weakest: output_clarity, error_handling
- `new-codebase-onboarding-routine` (routine) — 22/36; weakest: usefulness, output_clarity, error_handling

## All resources

| Resource | Type | Domain | Words | specificity | completeness | usefulness | reusability | distinctiveness | output clarity | error handling | safety | compatibility | Total | Nearest (overlap) |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `agent-workflow-designer-agent` | agent | ai-machine-learning | 1328 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 33 | mcp-server-design-agent (0%) |
| `ai-architecture-assessment-agent` | agent | ai-machine-learning | 1265 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | onboarding-flow-design-agent (0%) |
| `ai-cost-optimization-agent` | agent | ai-machine-learning | 1311 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | model-selection-analyst-agent (1%) |
| `ai-guardrails-design-agent` | agent | ai-machine-learning | 1293 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | ai-observability-analyst-agent (0%) |
| `ai-observability-analyst-agent` | agent | ai-machine-learning | 1272 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | agent-workflow-designer-agent (0%) |
| `embedding-strategy-agent` | agent | ai-machine-learning | 1259 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 30 | vector-database-evaluation-agent (0%) |
| `fine-tuning-readiness-agent` | agent | ai-machine-learning | 1282 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 33 | ml-experiment-review-agent (0%) |
| `llm-evaluation-agent` | agent | ai-machine-learning | 1324 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 31 | model-selection-analyst-agent (0%) |
| `mcp-server-design-agent` | agent | ai-machine-learning | 1411 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | agent-workflow-designer-agent (0%) |
| `ml-experiment-review-agent` | agent | ai-machine-learning | 1245 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | fine-tuning-readiness-agent (0%) |
| `model-selection-analyst-agent` | agent | ai-machine-learning | 1287 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | ai-cost-optimization-agent (1%) |
| `prompt-injection-assessment-agent` | agent | ai-machine-learning | 1279 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | long-document-analysis-agent (0%) |
| `rag-evaluation-agent` | agent | ai-machine-learning | 1454 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | retrieval-quality-metrics (0%) |
| `vector-database-evaluation-agent` | agent | ai-machine-learning | 1275 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | embedding-strategy-agent (0%) |
| `eval-test-case-generator-prompt` | prompt | ai-machine-learning | 844 | 3 | 4 | 4 | 4 | 4 | 1 | 0 | 1 | 4 | 25 | - (0%) |
| `few-shot-example-generator-prompt` | prompt | ai-machine-learning | 834 | 4 | 4 | 4 | 4 | 4 | 1 | 0 | 1 | 4 | 26 | - (0%) |
| `llm-output-critique-prompt` | prompt | ai-machine-learning | 754 | 4 | 4 | 4 | 4 | 4 | 2 | 0 | 2 | 4 | 28 | strategy-options-evaluation-prompt (0%) |
| `rag-answer-grounding-prompt` | prompt | ai-machine-learning | 817 | 4 | 4 | 4 | 4 | 4 | 1 | 0 | 1 | 4 | 26 | financial-results-commentary-prompt (0%) |
| `system-prompt-architect-prompt` | prompt | ai-machine-learning | 954 | 4 | 4 | 4 | 4 | 4 | 1 | 0 | 1 | 4 | 26 | aml-alert-review-agent (0%) |
| `llm-feature-launch-routine` | routine | ai-machine-learning | 1008 | 2 | 4 | 1 | 4 | 4 | 0 | 0 | 2 | 4 | 21 | model-upgrade-regression-routine (0%) |
| `model-upgrade-regression-routine` | routine | ai-machine-learning | 968 | 2 | 4 | 1 | 4 | 4 | 0 | 0 | 2 | 4 | 21 | llm-feature-launch-routine (0%) |
| `rag-pipeline-evaluation-routine` | routine | ai-machine-learning | 937 | 2 | 4 | 1 | 4 | 4 | 0 | 0 | 2 | 4 | 21 | rag-evaluation-agent (0%) |
| `agent-trace-debugging` | skill | ai-machine-learning | 707 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `chunking-strategy-design` | skill | ai-machine-learning | 765 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | - (0%) |
| `context-window-management` | skill | ai-machine-learning | 753 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | - (0%) |
| `data-labeling-guidelines` | skill | ai-machine-learning | 712 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 28 | llm-judge-rubric-design (0%) |
| `golden-dataset-construction` | skill | ai-machine-learning | 716 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | hallucination-detection (0%) |
| `hallucination-detection` | skill | ai-machine-learning | 650 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | citation-management (0%) |
| `hybrid-search-tuning` | skill | ai-machine-learning | 720 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 28 | - (0%) |
| `jailbreak-red-teaming` | skill | ai-machine-learning | 802 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | ai-guardrails-design-agent (0%) |
| `llm-judge-rubric-design` | skill | ai-machine-learning | 677 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | data-labeling-guidelines (0%) |
| `model-card-writing` | skill | ai-machine-learning | 660 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | ml-experiment-review-agent (0%) |
| `prompt-optimization` | skill | ai-machine-learning | 666 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `retrieval-quality-metrics` | skill | ai-machine-learning | 676 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | rag-evaluation-agent (0%) |
| `structured-output-extraction` | skill | ai-machine-learning | 664 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 28 | - (0%) |
| `token-budget-estimation` | skill | ai-machine-learning | 719 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 29 | ai-cost-optimization-agent (0%) |
| `tool-schema-design` | skill | ai-machine-learning | 661 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | mcp-server-design-agent (0%) |
| `board-update-drafting-agent` | agent | business-strategy | 1102 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | executive-research-memo-prompt (0%) |
| `business-case-development-agent` | agent | business-strategy | 1418 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 3 | 4 | 32 | literature-review-agent (0%) |
| `change-management-planning-agent` | agent | business-strategy | 1201 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | patent-landscape-agent (0%) |
| `okr-design-agent` | agent | business-strategy | 1073 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | analytics-pipeline-review-agent (0%) |
| `operating-model-analyst-agent` | agent | business-strategy | 1226 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | okr-design-agent (0%) |
| `partnership-evaluation-agent` | agent | business-strategy | 1128 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | competitor-research-agent (0%) |
| `pricing-strategy-agent` | agent | business-strategy | 1235 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | product-marketing-positioning-agent (0%) |
| `process-improvement-agent` | agent | business-strategy | 1245 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | data-model-design-agent (0%) |
| `strategic-planning-agent` | agent | business-strategy | 1176 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | competitor-research-agent (0%) |
| `business-model-canvas-prompt` | prompt | business-strategy | 763 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 28 | - (0%) |
| `executive-summary-prompt` | prompt | business-strategy | 714 | 4 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 27 | - (0%) |
| `strategy-options-evaluation-prompt` | prompt | business-strategy | 735 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 28 | llm-output-critique-prompt (0%) |
| `annual-strategic-planning-routine` | routine | business-strategy | 948 | 2 | 4 | 1 | 4 | 4 | 1 | 1 | 2 | 4 | 23 | - (0%) |
| `quarterly-business-review-routine` | routine | business-strategy | 975 | 2 | 4 | 1 | 4 | 4 | 1 | 1 | 2 | 4 | 23 | product-discovery-sprint-routine (0%) |
| `decision-memo-writing` | skill | business-strategy | 698 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 28 | - (0%) |
| `industry-structure-analysis` | skill | business-strategy | 723 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | - (0%) |
| `kpi-tree-design` | skill | business-strategy | 742 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 1 | 4 | 28 | - (0%) |
| `raci-matrix-design` | skill | business-strategy | 724 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 28 | - (0%) |
| `risk-register-construction` | skill | business-strategy | 682 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 28 | - (0%) |
| `scenario-planning` | skill | business-strategy | 706 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | - (0%) |
| `stakeholder-mapping` | skill | business-strategy | 704 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | banking-operations-analyst-agent (0%) |
| `unit-economics-analysis` | skill | business-strategy | 744 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 27 | - (0%) |
| `value-stream-mapping` | skill | business-strategy | 750 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 28 | - (0%) |
| `analytics-pipeline-review-agent` | agent | data-analytics | 1149 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | dbt-model-review (0%) |
| `bi-dashboard-specification-agent` | agent | data-analytics | 1258 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 29 | financial-reconciliation-agent (0%) |
| `cohort-retention-analysis-agent` | agent | data-analytics | 1204 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | data-quality-investigation-agent (0%) |
| `data-model-design-agent` | agent | data-analytics | 1203 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 29 | process-improvement-agent (0%) |
| `data-quality-investigation-agent` | agent | data-analytics | 1243 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | cohort-retention-analysis-agent (0%) |
| `experiment-analysis-agent` | agent | data-analytics | 1225 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | campaign-performance-analyst-agent (0%) |
| `metric-anomaly-investigation-agent` | agent | data-analytics | 1214 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | technical-research-agent (0%) |
| `sql-analysis-agent` | agent | data-analytics | 1363 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | sql-from-question-prompt (0%) |
| `insight-narrative-prompt` | prompt | data-analytics | 867 | 4 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 27 | campaign-performance-analyst-agent (0%) |
| `sql-from-question-prompt` | prompt | data-analytics | 880 | 4 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 27 | sql-analysis-agent (0%) |
| `weekly-metrics-review-routine` | routine | data-analytics | 1057 | 2 | 4 | 1 | 4 | 4 | 0 | 1 | 2 | 4 | 22 | weekly-competitive-intelligence-routine (0%) |
| `chart-selection` | skill | data-analytics | 815 | 3 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 26 | - (0%) |
| `data-dictionary-authoring` | skill | data-analytics | 735 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `data-profiling` | skill | data-analytics | 693 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | sql-analysis-agent (0%) |
| `dbt-model-review` | skill | data-analytics | 855 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | analytics-pipeline-review-agent (0%) |
| `metric-definition` | skill | data-analytics | 703 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 27 | - (0%) |
| `sql-query-review` | skill | data-analytics | 893 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | sql-from-question-prompt (0%) |
| `statistical-significance-testing` | skill | data-analytics | 856 | 3 | 4 | 4 | 4 | 4 | 2 | 1 | 1 | 4 | 27 | - (0%) |
| `time-series-forecast-review` | skill | data-analytics | 821 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | data-quality-investigation-agent (0%) |
| `aml-alert-review-agent` | agent | finance-banking | 1348 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | banking-operations-analyst-agent (0%) |
| `banking-operations-analyst-agent` | agent | finance-banking | 1124 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | fraud-pattern-investigation-agent (0%) |
| `budget-variance-analysis-agent` | agent | finance-banking | 1104 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | financial-results-commentary-prompt (0%) |
| `cash-flow-forecasting-agent` | agent | finance-banking | 1114 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | board-update-drafting-agent (0%) |
| `credit-risk-analysis-agent` | agent | finance-banking | 1217 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | credit-application-review-routine (0%) |
| `financial-reconciliation-agent` | agent | finance-banking | 1090 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | month-end-close-routine (0%) |
| `financial-statement-analysis-agent` | agent | finance-banking | 1452 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | three-statement-model-review (0%) |
| `fraud-pattern-investigation-agent` | agent | finance-banking | 1126 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | banking-operations-analyst-agent (0%) |
| `financial-results-commentary-prompt` | prompt | finance-banking | 721 | 3 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 24 | budget-variance-analysis-agent (0%) |
| `investment-memo-prompt` | prompt | finance-banking | 665 | 2 | 4 | 4 | 4 | 4 | 0 | 0 | 2 | 4 | 24 | - (0%) |
| `credit-application-review-routine` | routine | finance-banking | 810 | 2 | 4 | 1 | 4 | 4 | 1 | 2 | 1 | 4 | 23 | credit-risk-analysis-agent (0%) |
| `month-end-close-routine` | routine | finance-banking | 888 | 2 | 4 | 1 | 4 | 4 | 1 | 2 | 2 | 4 | 24 | financial-reconciliation-agent (0%) |
| `dcf-valuation` | skill | finance-banking | 765 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | strategic-planning-agent (0%) |
| `earnings-call-analysis` | skill | finance-banking | 577 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | long-document-analysis-agent (0%) |
| `financial-ratio-analysis` | skill | finance-banking | 744 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 29 | financial-statement-analysis-agent (0%) |
| `journal-entry-review` | skill | finance-banking | 685 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | three-statement-model-review (0%) |
| `kyc-document-review` | skill | finance-banking | 745 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 4 | 4 | 30 | aml-alert-review-agent (0%) |
| `loan-covenant-analysis` | skill | finance-banking | 648 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 29 | - (0%) |
| `three-statement-model-review` | skill | finance-banking | 696 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 29 | financial-statement-analysis-agent (0%) |
| `working-capital-analysis` | skill | finance-banking | 627 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | credit-risk-analysis-agent (0%) |
| `brand-voice-guardian-agent` | agent | marketing-growth | 1152 | 3 | 4 | 4 | 4 | 4 | 4 | 1 | 3 | 4 | 31 | product-analytics-instrumentation-agent (0%) |
| `campaign-performance-analyst-agent` | agent | marketing-growth | 1164 | 3 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 32 | insight-narrative-prompt (0%) |
| `content-strategy-agent` | agent | marketing-growth | 1244 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | compliance-gap-analysis-agent (0%) |
| `conversion-optimization-agent` | agent | marketing-growth | 1314 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | ab-test-design (0%) |
| `email-lifecycle-agent` | agent | marketing-growth | 1257 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | social-media-strategy-agent (0%) |
| `paid-search-optimization-agent` | agent | marketing-growth | 1341 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | ai-cost-optimization-agent (0%) |
| `product-marketing-positioning-agent` | agent | marketing-growth | 1265 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | pricing-strategy-agent (0%) |
| `seo-audit-agent` | agent | marketing-growth | 1456 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | monthly-seo-health-check-routine (0%) |
| `social-media-strategy-agent` | agent | marketing-growth | 1256 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | content-strategy-agent (0%) |
| `ad-copy-variations-prompt` | prompt | marketing-growth | 855 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | paid-search-optimization-agent (0%) |
| `blog-post-outline-prompt` | prompt | marketing-growth | 837 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | content-brief-creation (0%) |
| `value-proposition-prompt` | prompt | marketing-growth | 775 | 3 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 24 | write-tests-for-function-prompt (0%) |
| `campaign-launch-routine` | routine | marketing-growth | 1255 | 2 | 4 | 1 | 4 | 4 | 0 | 2 | 4 | 4 | 25 | feature-launch-routine (0%) |
| `monthly-seo-health-check-routine` | routine | marketing-growth | 1249 | 2 | 4 | 1 | 4 | 4 | 0 | 2 | 2 | 4 | 23 | seo-audit-agent (0%) |
| `ab-test-design` | skill | marketing-growth | 846 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | conversion-optimization-agent (0%) |
| `content-brief-creation` | skill | marketing-growth | 763 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 1 | 4 | 27 | blog-post-outline-prompt (0%) |
| `customer-segmentation` | skill | marketing-growth | 757 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `keyword-research` | skill | marketing-growth | 831 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | blog-post-outline-prompt (0%) |
| `landing-page-copywriting` | skill | marketing-growth | 835 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | messaging-framework (0%) |
| `marketing-attribution-analysis` | skill | marketing-growth | 743 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | rag-pipeline-evaluation-routine (0%) |
| `messaging-framework` | skill | marketing-growth | 705 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | data-classification (0%) |
| `on-page-seo-optimization` | skill | marketing-growth | 880 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | - (0%) |
| `technical-seo-crawl-analysis` | skill | marketing-growth | 873 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | seo-audit-agent (0%) |
| `design-system-audit-agent` | agent | product-design | 1161 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | pull-request-review-agent (0%) |
| `feature-prioritization-agent` | agent | product-design | 1202 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | rice-prioritization (0%) |
| `onboarding-flow-design-agent` | agent | product-design | 1237 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | design-system-audit-agent (0%) |
| `prd-generation-agent` | agent | product-design | 1503 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | technical-documentation-agent (0%) |
| `product-analytics-instrumentation-agent` | agent | product-design | 1233 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | pricing-strategy-agent (0%) |
| `product-discovery-agent` | agent | product-design | 1327 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | feature-prioritization-agent (0%) |
| `product-roadmap-analyst-agent` | agent | product-design | 1262 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 3 | 4 | 32 | feature-prioritization-agent (0%) |
| `usability-heuristic-review-agent` | agent | product-design | 1184 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 33 | ai-architecture-assessment-agent (0%) |
| `ux-research-synthesis-agent` | agent | product-design | 1239 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | test-strategy-agent (0%) |
| `feature-spec-prompt` | prompt | product-design | 713 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | release-announcement-prompt (0%) |
| `release-announcement-prompt` | prompt | product-design | 731 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 2 | 4 | 26 | feature-spec-prompt (0%) |
| `user-interview-script-prompt` | prompt | product-design | 926 | 4 | 4 | 4 | 4 | 4 | 1 | 0 | 2 | 4 | 27 | expert-interview-guide (0%) |
| `feature-launch-routine` | routine | product-design | 925 | 2 | 4 | 1 | 4 | 4 | 1 | 0 | 2 | 4 | 22 | campaign-launch-routine (0%) |
| `product-discovery-sprint-routine` | routine | product-design | 931 | 2 | 4 | 1 | 4 | 4 | 1 | 0 | 2 | 4 | 22 | opportunity-solution-tree (0%) |
| `acceptance-criteria-gherkin` | skill | product-design | 778 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `accessibility-design-review` | skill | product-design | 1046 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 1 | 4 | 29 | frontend-accessibility-review-agent (0%) |
| `jobs-to-be-done-analysis` | skill | product-design | 815 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | budget-variance-analysis-agent (0%) |
| `journey-mapping` | skill | product-design | 706 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | feature-prioritization-agent (0%) |
| `opportunity-solution-tree` | skill | product-design | 801 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | product-discovery-sprint-routine (0%) |
| `persona-development` | skill | product-design | 774 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 31 | - (0%) |
| `rice-prioritization` | skill | product-design | 750 | 4 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 30 | feature-prioritization-agent (0%) |
| `user-story-writing` | skill | product-design | 766 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `ux-copy-review` | skill | product-design | 795 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | owasp-top-10-review (0%) |
| `email-triage-agent` | agent | productivity-knowledge | 1317 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 33 | long-document-analysis-agent (0%) |
| `knowledge-base-curator-agent` | agent | productivity-knowledge | 1424 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | legacy-modernization-agent (0%) |
| `learning-plan-agent` | agent | productivity-knowledge | 1195 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | fact-checking-agent (0%) |
| `long-document-analysis-agent` | agent | productivity-knowledge | 1182 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 2 | 4 | 31 | earnings-call-analysis (0%) |
| `meeting-intelligence-agent` | agent | productivity-knowledge | 1203 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | executive-research-memo-prompt (0%) |
| `personal-planning-agent` | agent | productivity-knowledge | 1103 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 3 | 4 | 32 | meeting-intelligence-agent (0%) |
| `technical-documentation-agent` | agent | productivity-knowledge | 1167 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | executive-research-memo-prompt (0%) |
| `weekly-review-prompt` | prompt | productivity-knowledge | 813 | 4 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 27 | weekly-planning-routine (0%) |
| `weekly-planning-routine` | routine | productivity-knowledge | 1072 | 4 | 4 | 4 | 3 | 4 | 4 | 1 | 2 | 4 | 30 | weekly-review-prompt (0%) |
| `action-item-extraction` | skill | productivity-knowledge | 785 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | meeting-intelligence-agent (0%) |
| `atomic-note-writing` | skill | productivity-knowledge | 779 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 30 | - (0%) |
| `decision-log-maintenance` | skill | productivity-knowledge | 797 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | - (0%) |
| `meeting-notes-structuring` | skill | productivity-knowledge | 697 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | - (0%) |
| `plain-language-rewriting` | skill | productivity-knowledge | 737 | 3 | 4 | 2 | 4 | 4 | 2 | 0 | 2 | 4 | 25 | - (0%) |
| `sop-writing` | skill | productivity-knowledge | 841 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | - (0%) |
| `competitor-research-agent` | agent | research-intelligence | 1173 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | partnership-evaluation-agent (0%) |
| `customer-voice-research-agent` | agent | research-intelligence | 1096 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | jobs-to-be-done-analysis (0%) |
| `due-diligence-research-agent` | agent | research-intelligence | 1244 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | company-profile-research (0%) |
| `fact-checking-agent` | agent | research-intelligence | 955 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 30 | learning-plan-agent (0%) |
| `literature-review-agent` | agent | research-intelligence | 1186 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | business-case-development-agent (0%) |
| `market-intelligence-agent` | agent | research-intelligence | 1064 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | market-sizing (0%) |
| `patent-landscape-agent` | agent | research-intelligence | 1151 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | dependency-upgrade-agent (0%) |
| `regulatory-horizon-scanning-agent` | agent | research-intelligence | 1153 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 30 | data-classification (0%) |
| `technical-research-agent` | agent | research-intelligence | 1069 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 3 | 4 | 32 | metric-anomaly-investigation-agent (0%) |
| `technology-radar-agent` | agent | research-intelligence | 1057 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | learning-plan-agent (0%) |
| `competitor-battlecard-prompt` | prompt | research-intelligence | 716 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 2 | 4 | 26 | release-announcement-prompt (0%) |
| `deep-research-brief-prompt` | prompt | research-intelligence | 777 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | - (0%) |
| `executive-research-memo-prompt` | prompt | research-intelligence | 678 | 3 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 24 | board-update-drafting-agent (0%) |
| `research-paper-summary-prompt` | prompt | research-intelligence | 690 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | - (0%) |
| `vendor-evaluation-research-routine` | routine | research-intelligence | 887 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 29 | vendor-security-assessment-agent (0%) |
| `weekly-competitive-intelligence-routine` | routine | research-intelligence | 895 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 29 | vendor-evaluation-research-routine (0%) |
| `citation-management` | skill | research-intelligence | 659 | 3 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 29 | hallucination-detection (0%) |
| `company-profile-research` | skill | research-intelligence | 707 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | due-diligence-research-agent (0%) |
| `competitive-feature-matrix` | skill | research-intelligence | 685 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `evidence-based-swot` | skill | research-intelligence | 654 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | - (0%) |
| `expert-interview-guide` | skill | research-intelligence | 748 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | user-interview-script-prompt (0%) |
| `market-sizing` | skill | research-intelligence | 720 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | market-intelligence-agent (0%) |
| `research-synthesis-matrix` | skill | research-intelligence | 675 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `search-query-formulation` | skill | research-intelligence | 682 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `source-credibility-assessment` | skill | research-intelligence | 758 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | owasp-top-10-review (0%) |
| `trend-signal-detection` | skill | research-intelligence | 657 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `application-security-audit-agent` | agent | security-compliance | 1466 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | security-finding-writeup-prompt (1%) |
| `cloud-security-posture-agent` | agent | security-compliance | 1164 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 3 | 4 | 32 | security-architecture-review-agent (1%) |
| `compliance-gap-analysis-agent` | agent | security-compliance | 1203 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | content-strategy-agent (0%) |
| `incident-response-coordinator-agent` | agent | security-compliance | 1292 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | prd-generation-agent (0%) |
| `privacy-impact-assessment-agent` | agent | security-compliance | 1218 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | market-intelligence-agent (0%) |
| `security-architecture-review-agent` | agent | security-compliance | 1218 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | cloud-security-posture-agent (1%) |
| `threat-modeling-agent` | agent | security-compliance | 1263 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | stride-threat-enumeration (1%) |
| `vendor-security-assessment-agent` | agent | security-compliance | 1147 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | vendor-evaluation-research-routine (0%) |
| `security-finding-writeup-prompt` | prompt | security-compliance | 787 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 2 | 4 | 26 | application-security-audit-agent (1%) |
| `security-questionnaire-response-prompt` | prompt | security-compliance | 708 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | knowledge-base-curator-agent (0%) |
| `quarterly-access-review-routine` | routine | security-compliance | 1026 | 2 | 4 | 1 | 4 | 4 | 0 | 2 | 3 | 4 | 24 | - (0%) |
| `access-review` | skill | security-compliance | 782 | 3 | 4 | 2 | 4 | 4 | 2 | 0 | 2 | 4 | 25 | experiment-analysis-agent (0%) |
| `data-classification` | skill | security-compliance | 769 | 4 | 4 | 2 | 4 | 4 | 2 | 0 | 2 | 4 | 26 | security-policy-writing (0%) |
| `dependency-vulnerability-triage` | skill | security-compliance | 836 | 3 | 4 | 2 | 4 | 4 | 1 | 0 | 3 | 4 | 25 | threat-modeling-agent (0%) |
| `owasp-top-10-review` | skill | security-compliance | 823 | 3 | 4 | 4 | 4 | 4 | 1 | 0 | 2 | 4 | 26 | secrets-exposure-review (0%) |
| `secrets-exposure-review` | skill | security-compliance | 839 | 2 | 4 | 2 | 4 | 4 | 1 | 0 | 3 | 4 | 24 | owasp-top-10-review (0%) |
| `security-log-analysis` | skill | security-compliance | 837 | 3 | 4 | 2 | 4 | 4 | 2 | 0 | 2 | 4 | 25 | budget-variance-analysis-agent (0%) |
| `security-policy-writing` | skill | security-compliance | 780 | 2 | 4 | 2 | 4 | 4 | 1 | 0 | 2 | 4 | 23 | data-classification (0%) |
| `stride-threat-enumeration` | skill | security-compliance | 889 | 3 | 4 | 2 | 4 | 4 | 1 | 0 | 2 | 4 | 24 | threat-modeling-agent (1%) |
| `api-design-review-agent` | agent | software-development | 1339 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | data-model-design-agent (0%) |
| `architecture-review-agent` | agent | software-development | 1405 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | ml-experiment-review-agent (0%) |
| `cicd-troubleshooting-agent` | agent | software-development | 1331 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | cloud-security-posture-agent (0%) |
| `code-refactoring-agent` | agent | software-development | 1318 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | write-tests-for-function-prompt (0%) |
| `concurrency-bug-analysis-agent` | agent | software-development | 1488 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | frontend-accessibility-review-agent (0%) |
| `database-migration-planner-agent` | agent | software-development | 1412 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 33 | product-analytics-instrumentation-agent (0%) |
| `database-performance-agent` | agent | software-development | 1401 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | seo-audit-agent (0%) |
| `dependency-upgrade-agent` | agent | software-development | 1317 | 4 | 4 | 4 | 4 | 4 | 4 | 1 | 4 | 4 | 33 | patent-landscape-agent (0%) |
| `frontend-accessibility-review-agent` | agent | software-development | 1489 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | accessibility-design-review (0%) |
| `infrastructure-as-code-review-agent` | agent | software-development | 1266 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | frontend-accessibility-review-agent (0%) |
| `legacy-modernization-agent` | agent | software-development | 1402 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | ai-cost-optimization-agent (0%) |
| `observability-instrumentation-agent` | agent | software-development | 1385 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | threat-modeling-agent (0%) |
| `performance-profiling-agent` | agent | software-development | 1320 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 3 | 4 | 31 | database-performance-agent (0%) |
| `production-incident-debugger-agent` | agent | software-development | 1480 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | financial-reconciliation-agent (0%) |
| `pull-request-review-agent` | agent | software-development | 1206 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | structured-code-review (0%) |
| `repository-intelligence-agent` | agent | software-development | 1324 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | cloud-security-posture-agent (0%) |
| `technical-debt-assessment-agent` | agent | software-development | 1239 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | ai-observability-analyst-agent (0%) |
| `test-strategy-agent` | agent | software-development | 1267 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 4 | 4 | 32 | embedding-strategy-agent (0%) |
| `code-review-feedback-prompt` | prompt | software-development | 647 | 3 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 26 | pull-request-review-routine (0%) |
| `debug-error-message-prompt` | prompt | software-development | 767 | 4 | 4 | 4 | 4 | 4 | 1 | 0 | 1 | 4 | 26 | performance-profiling-agent (0%) |
| `explain-unfamiliar-code-prompt` | prompt | software-development | 822 | 4 | 4 | 4 | 4 | 4 | 1 | 0 | 1 | 4 | 26 | code-review-feedback-prompt (0%) |
| `technical-design-doc-prompt` | prompt | software-development | 796 | 4 | 4 | 4 | 4 | 4 | 0 | 0 | 1 | 4 | 25 | - (0%) |
| `write-tests-for-function-prompt` | prompt | software-development | 776 | 4 | 4 | 4 | 4 | 4 | 2 | 0 | 1 | 4 | 27 | unit-test-design (0%) |
| `incident-postmortem-routine` | routine | software-development | 1039 | 3 | 4 | 4 | 3 | 4 | 3 | 2 | 2 | 4 | 29 | quarterly-business-review-routine (0%) |
| `new-codebase-onboarding-routine` | routine | software-development | 1127 | 2 | 4 | 1 | 3 | 4 | 0 | 1 | 3 | 4 | 22 | git-history-forensics (0%) |
| `pull-request-review-routine` | routine | software-development | 990 | 3 | 4 | 4 | 3 | 4 | 2 | 2 | 3 | 4 | 29 | code-review-feedback-prompt (0%) |
| `release-readiness-routine` | routine | software-development | 1045 | 3 | 4 | 4 | 3 | 4 | 3 | 1 | 2 | 4 | 28 | - (0%) |
| `architecture-decision-records` | skill | software-development | 762 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | ai-architecture-assessment-agent (0%) |
| `changelog-and-release-notes` | skill | software-development | 871 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | weekly-metrics-review-routine (0%) |
| `code-complexity-analysis` | skill | software-development | 810 | 3 | 3 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 27 | - (0%) |
| `commit-message-writing` | skill | software-development | 755 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `database-index-design` | skill | software-development | 933 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `dockerfile-hardening` | skill | software-development | 816 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | - (0%) |
| `error-handling-review` | skill | software-development | 819 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | dbt-model-review (0%) |
| `feature-flag-rollout-planning` | skill | software-development | 941 | 3 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 29 | - (0%) |
| `flaky-test-diagnosis` | skill | software-development | 920 | 2 | 4 | 4 | 4 | 4 | 2 | 0 | 2 | 4 | 26 | - (0%) |
| `git-history-forensics` | skill | software-development | 1052 | 4 | 4 | 4 | 4 | 4 | 4 | 0 | 2 | 4 | 30 | new-codebase-onboarding-routine (0%) |
| `graphql-schema-review` | skill | software-development | 880 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `openapi-spec-authoring` | skill | software-development | 821 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `readme-authoring` | skill | software-development | 825 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | - (0%) |
| `regex-construction-and-testing` | skill | software-development | 841 | 4 | 4 | 4 | 4 | 4 | 3 | 1 | 2 | 4 | 30 | - (0%) |
| `sql-query-optimization` | skill | software-development | 933 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 28 | sql-query-review (0%) |
| `stack-trace-analysis` | skill | software-development | 945 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | - (0%) |
| `structured-code-review` | skill | software-development | 832 | 3 | 4 | 4 | 4 | 4 | 3 | 0 | 3 | 4 | 29 | pull-request-review-agent (0%) |
| `unit-test-design` | skill | software-development | 780 | 4 | 4 | 4 | 4 | 4 | 3 | 0 | 2 | 4 | 29 | write-tests-for-function-prompt (0%) |
