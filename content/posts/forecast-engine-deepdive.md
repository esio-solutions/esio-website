---
title: "How the forecast engine actually works"
description: "A short technical post for customers who like to know what's running under the hood."
date: 2026-03-15
---

A few customers have asked: how does ESIO know what your bank balance will look like in October? Here's the short version.

## Three signals, one model

We combine three streams:

1. **Recurring patterns** — payroll, rent, subscriptions, regular revenue. Pulled from your accounting integration; classified via a small classifier we trained on 12 months of anonymised data.
2. **Known events** — invoices already issued (with their due dates), tax deadlines from the calendar, scheduled hires.
3. **Variability** — the noise in your historical data. We don't pretend forecasts are deterministic; instead each daily balance is reported with a confidence band.

Combined into a daily simulation 540 days forward. Re-runs on every data refresh.

## Where it's good vs. where it's not

It's accurate to within 5% on the 30-day horizon for businesses with 6+ months of history. The uncertainty band widens past 6 months — that's not a bug, that's reality. We surface the uncertainty rather than hide it, because a single number with false precision is worse than a range with honest ones.

It's less accurate for very lumpy businesses (project-based agencies, high-ticket sales). For those, the scenario planner is the better tool.

If you're newer to forecasting and want the customer-facing rationale rather than engineering details, [our article on building a first-year forecast](/articles/forecasting-first-year/) covers the same ground from the other side.
