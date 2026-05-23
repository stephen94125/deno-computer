# Choosing a Statistics Library

## Context

For `deno-computer`, the goal is not to build a full data-science runtime. The goal is to give the LLM a stable, familiar, and low-friction statistics toolkit for business analysis workflows.

The priority is:

1. LLM familiarity
2. Low chance of generated-code mistakes
3. Enough coverage for business reporting and basic analytics
4. Avoid unnecessary scientific-computing complexity in the MVP

## Recommendation

Use **`simple-statistics`** as the default statistics library.

It is not the only option in the TypeScript / JavaScript ecosystem, but it is the best default for this use case: simple, common, easy for LLMs to write correctly, and sufficient for most business-analysis needs.

Typical use cases:

- mean / median / mode
- variance / standard deviation
- quantiles
- correlation
- simple linear regression
- basic inference utilities
- anomaly checks based on simple statistical rules

## Option 1: `simple-statistics`

**Role:** Default business-analysis statistics library.

`simple-statistics` is suitable for everyday commercial reporting and lightweight analytics. It covers the common statistical operations needed for sales reports, product ranking, revenue comparison, outlier detection, and simple trend analysis.

Use this when the workflow needs:

- Descriptive statistics
- Simple regression
- Correlation
- Quantiles
- Basic anomaly detection
- LLM-generated code that should stay easy and predictable

**Decision:** Install by default.

## Option 2: `jstat`

**Role:** Traditional statistics / probability-distribution library.

`jstat` has more probability-distribution functions, such as:

- PDF / CDF / inverse CDF
- Poisson distribution
- Beta distribution
- Hypergeometric distribution
- Other distribution-oriented utilities

However, it feels more like a traditional statistics package. For daily business reporting and MVP workflows, this is usually unnecessary.

Use this later only if the workflow really needs probability distributions or more classical statistical modeling.

**Decision:** Do not install by default.

## Option 3: `@stdlib/stats`

**Role:** Larger and more serious scientific / numerical statistics standard library.

`@stdlib/stats` is broader and more hardcore. It is closer to a scientific-computing toolkit than a simple business-analysis helper.

It may be useful for more advanced numerical or statistical work, but for an LLM-driven MVP it adds too much cognitive overhead.

Use this later only if the project grows toward heavier scientific computing or numerical analysis.

**Decision:** Do not install by default.

## Final Decision

For the first version of `deno-computer`:

```bash
deno add simple-statistics
```

Do not add `jstat` or `@stdlib/stats` yet.

The principle is:

> Choose the library that the LLM is most likely to use correctly, not the library with the largest theoretical feature set.
