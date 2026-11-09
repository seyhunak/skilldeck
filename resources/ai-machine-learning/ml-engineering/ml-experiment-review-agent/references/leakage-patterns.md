# Leakage patterns

Check each pattern against the code. Most leakage inflates offline metrics and disappears in production.

| Pattern | What it looks like in code | Why it leaks | How to confirm |
|---|---|---|---|
| Preprocessing before split | `fit` on scaler, imputer, encoder, or vectorizer called on the full dataset, then split | Test statistics influence training features | Move fitting inside the training fold or pipeline; compare metrics |
| Feature selection before split | Correlation or importance filtering on all rows | Selected features are tuned to the test labels | Redo selection within folds |
| Oversampling before split | SMOTE or duplication applied before splitting | Synthetic or copied rows appear on both sides | Resample only training data |
| Group leakage | Random row split where users, patients, devices, or documents have many rows | Model memorizes the entity, not the pattern | Group-aware split; compare metrics |
| Temporal leakage | Random split for a forecasting task; features using future windows | Model sees the future | Strict time-based split; audit feature timestamps |
| Target-derived features | Features computed from or after the outcome (for example "days since cancellation" in churn) | Feature encodes the label | Check each feature's availability time against prediction time |
| Proxy labels | A feature that is recorded only when the outcome happens (for example a follow-up code) | Near-perfect separation | Look for suspiciously high single-feature importance |
| Duplicates across splits | Exact or near-duplicate rows, images, or texts in train and test | Memorization scored as generalization | Hash and near-duplicate search across splits |
| Test-set tuning | Thresholds, early stopping, or model choice decided on test metrics | Optimistic bias | Re-tune on validation only; report test once |
| Global normalization of time series | Normalizing with mean and variance of the whole series | Future values shape past features | Rolling or training-window statistics |
| Label noise correlated with source | One data source has both easier labels and is over-represented in test | Gains reflect source mix | Report by source |
| Pretraining contamination | Evaluation items present in a pretrained model's training data | Benchmark memorization | Use fresh or private test items; check for verbatim recall |

## Red flags that justify a closer look

- A single feature with dominant importance.
- Test performance higher than validation performance.
- A large jump from a simple change.
- Near-perfect metrics on a task humans find hard.
- Offline gains that vanish in a shadow deployment.
