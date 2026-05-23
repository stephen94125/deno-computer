# 002 - Choosing the Date Library

## Decision

Use **date-fns** for the first version of `deno-computer`.

```bash
deno add date-fns
```

## Why date-fns

The goal is not to use the newest or most elegant date/time system. The goal is to choose the option that an LLM is most likely to write correctly without overthinking.

`date-fns` is a good default because:

- It is widely used and familiar to LLMs.
- Its API is simple and function-based.
- It is enough for business-reporting tasks.
- It handles common date operations cleanly: add/subtract days, format dates, start/end of week/month, date comparisons, and ranges.

Typical use cases:

- today / yesterday
- this week / last week
- this month / last month
- order date ranges
- report date formatting
- adding or subtracting days
- comparing periods

## Future direction

When **Temporal** becomes consistently available and familiar across the target Deno/Node runtime and LLM-generated code, we can consider moving to native Temporal.

For now, keep date logic behind a small helper layer, for example:

```text
scripts/lib/business-date.ts
```

This keeps the workflow stable and makes it easier to migrate from `date-fns` to `Temporal` later if needed.

## Final choice

```text
Current choice: date-fns
Future candidate: native Temporal
Do not use: Moment.js
```
