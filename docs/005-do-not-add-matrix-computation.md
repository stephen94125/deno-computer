# 005 - Do Not Add Matrix Computation

## Decision

Do **not** add a dedicated matrix computation library to `deno-computer` for the first version.

The JavaScript / TypeScript matrix computation ecosystem is not strong enough to justify adding a matrix package by default.

## Reason

`deno-computer` is designed for business analytics, not scientific computing.

The main workload is expected to be:

- grouping
- aggregation
- ranking
- deduplication
- growth rate calculation
- average / median / standard deviation
- outlier detection
- simple regression
- report preparation

These tasks do not require a dedicated matrix or linear algebra library.

## Current default

Use `mathjs` for simple matrix-related needs if they appear.

`mathjs` is already useful as a general-purpose math extension layer, and it can handle basic matrix operations well enough for occasional use.

## Only possible future option

### `ml-matrix`

`ml-matrix` is the only matrix-specific library worth considering later.

Possible use cases:

- matrix multiplication
- transpose
- inverse
- decomposition
- SVD / QR
- more serious linear algebra work

However, it should only be added when there is a concrete need.

Do not install it by default.

## Libraries not recommended

The following options should not be used as the default matrix layer:

### `numeric.js`

Old numerical JavaScript library.

Not suitable as a new project default.

### `ndarray` / `ndarray-ops` / SciJS ecosystem

Too fragmented and low-level.

Not suitable for LLM-generated business analytics code.

### `linear-algebra-js`, `Sylvester`, and similar libraries

Too old or too niche.

Not suitable as the default runtime library.

## Final rule

For now:

```bash
# Do not install a matrix-specific library
```

Use:

```bash
deno add mathjs
```

Only add `ml-matrix` later if a real linear algebra use case appears.
