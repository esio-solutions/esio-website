---
title: "v1.1: Faster forecasts and PDF exports"
description: "What landed in this week's release."
date: 2026-04-25
---

Two big improvements in this build, plus a handful of small ones.

## Forecasts run ~3× faster

We rewrote the forecasting engine to compute the next 18 months in a single pass instead of recursively. On real customer data, simulations that took 2.4 seconds now finish in 0.7. You'll feel it most when sliding scenario inputs.

## PDF exports

Every report now has a "Download PDF" button in the top-right. Useful for sending forecasts to your accountant, your board, or for the 18 months you'll inevitably need to print one.

## Smaller changes

- VAT calendar now correctly handles the 1 March deadline.
- Currency formatter uses the locale of the connected accounting system, not the browser.
- Fixed an off-by-one error in monthly comparisons that affected ~3% of users (sorry).

If you hit any rough edges, **support@esio.dk** reaches a human.
