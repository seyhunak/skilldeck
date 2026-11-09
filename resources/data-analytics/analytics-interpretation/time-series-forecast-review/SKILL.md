---
name: time-series-forecast-review
description: Reviews a time series forecast (demand, revenue, traffic, tickets) for data issues, seasonality and calendar handling, leakage, backtesting design, naive baselines, error metrics (MAE, RMSE, MAPE, sMAPE, MASE, WAPE), bias, and prediction-interval calibration. Use before a forecast is adopted for planning, when comparing forecasting approaches, or when a forecast keeps missing.
---

# Time Series Forecast Review

A forecast is useful only if it beats a simple baseline on data it has not seen, with errors measured in a way that matches how it will be used, and with uncertainty that is honest. This skill reviews a forecast the way a skeptical analyst would, regardless of the method (ETS, ARIMA, Prophet-style decomposition, gradient boosting, or a spreadsheet driver model).

## When to use

- A forecast is about to drive budgets, staffing, inventory, or targets.
- Choosing between forecasting methods or vendors.
- A forecast has missed repeatedly and someone needs to know why.
- Judging whether an observed value is outside the expected range.
- Not for building a forecasting model from scratch, and not a substitute for domain review of business assumptions.

## Inputs

- The historical series (or a description: frequency, length, level, obvious events).
- The forecast method, features, horizon, and how it was trained and evaluated.
- Backtest or holdout results, if any, and the prediction intervals.
- How the forecast will be used: decision, horizon that matters, cost of over- vs. under-forecasting.

## Procedure

1. **Inspect the history.** Plot the series. Note trend, seasonality (weekly, monthly, annual), structural breaks (pricing changes, launches, pandemics, tracking changes), outliers, missing periods, and whether volume is intermittent (many zeros). Check that the history is long enough to observe the seasonality being modeled; at least two full seasonal cycles is a common heuristic for estimating annual seasonality.
2. **Check calendar handling.** Holidays and moving events (Easter, Ramadan, Black Friday), trading-day differences between months, week definitions, and time zones. Misaligned holidays produce errors that look like model failure.
3. **Check for leakage.** Features must be known at forecast time: no future values, no aggregates computed over the full series (for example, scaling with the full-sample mean), no target-derived features that peek ahead. Exogenous drivers (marketing spend, price) must themselves be forecast or planned for the horizon; evaluating with actual future drivers overstates accuracy.
4. **Check the backtest design.** Random train/test splits are invalid for time series. Expect a rolling-origin (time series cross-validation) evaluation: several forecast origins, each trained only on data before it, evaluated at the horizons that matter. A single holdout period can be unrepresentative.
5. **Compare with baselines.** Naive (last value), seasonal naive (same period last season), and drift or moving average. A model that does not clearly beat seasonal naive on the backtest is not adding value, however sophisticated.
6. **Choose appropriate error metrics.** MAE (scale-dependent, robust, interpretable in units); RMSE (penalizes large errors); MAPE (undefined at zero and asymmetric, unreliable for low or intermittent volumes); sMAPE (bounded but has its own asymmetries); WAPE / weighted MAPE (sum of absolute errors divided by sum of actuals, good for aggregating across items); MASE (scales by in-sample seasonal naive error; values below 1 beat the naive method). Report error by horizon, and report **bias** (mean error) separately because a consistently high or low forecast matters for planning even with modest absolute error.
7. **Check prediction intervals.** Are intervals provided? In backtests, does the 80% interval contain roughly 80% of actuals (coverage)? Intervals that are too narrow are common, especially when they ignore parameter uncertainty or driver uncertainty.
8. **Check residuals.** Remaining autocorrelation or seasonality in residuals signals missed structure; residuals that grow with level suggest a log transform or multiplicative model.
9. **Assess fitness for use.** Match the evaluation to the decision: hierarchy and aggregation level (forecasting totals vs. SKUs), the horizon that drives the decision, asymmetric costs (stockouts vs. overstock), and how often it will be refreshed. Check that assumptions (growth rates, launch effects) are written down and owned.
10. **Summarize with recommendations.** Adopt, adopt with changes, or do not adopt; list fixes in priority order.

## Expected output

```markdown
## Forecast review: <series> (<frequency>, horizon <h>)
**Verdict:** Adopt | Adopt with changes | Do not adopt

| Area | Finding | Severity | Recommendation |
|---|---|---|---|
| Data and breaks | | | |
| Seasonality / calendar | | | |
| Leakage | | | |
| Backtest design | | | |
| Baselines | | | |
| Error metrics and bias | | | |
| Intervals | | | |
| Fitness for use | | | |

**Backtest summary:** | Horizon | Model MAE | Seasonal naive MAE | MASE | Bias | 80% coverage |
**Key assumptions to confirm with owners:** …
```

## Constraints and limitations

- Review relies on the evaluation evidence supplied; if no backtest exists, the main recommendation is to run one, and conclusions are provisional.
- No method forecasts unprecedented shocks; judge whether scenarios are needed alongside a point forecast.
- Thresholds such as "two seasonal cycles" are heuristics.
- Forecasts used for financial or operational commitments need sign-off by the accountable owner.

## Examples

A weekly ticket-volume forecast reports MAPE of 6% on a single 8-week holdout from March to April. Review findings: the holdout excludes the December peak, so error is likely understated; Easter fell in the holdout but is not modeled; seasonal naive scores a 7% MAPE on the same window, so the model's advantage is small; intervals cover 58% of actuals at the nominal 80% level. Recommendation: rolling-origin backtest across 52 weeks reporting MAE and MASE by horizon, add holiday regressors, and widen or recalibrate intervals before using the forecast for staffing.
