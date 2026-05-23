# 003 - Other Math Library

## Decision

Use **mathjs** as the default general-purpose math library for `deno-computer`.

It is not the only option, but it is the best default for this project because it is broad, common, and likely familiar to LLMs.

## Why mathjs

`mathjs` is suitable as the general math extension layer:

- General-purpose math toolbox
- Expressions and formula evaluation
- Matrix support
- Complex numbers
- Big numbers / fractions
- Units
- Familiar enough for LLM-generated TypeScript code

For `deno-computer`, this is good enough as the default math layer.

## What mathjs is not for

`mathjs` should not replace dedicated libraries for specific domains.

For business analytics, the main stack is still:

- `arquero` for table/data transformation
- `simple-statistics` for statistics
- `mathjs` for general math support

## Other options

### `decimal.js` / `big.js`

Use these only if precise decimal arithmetic becomes important.

Good for:

- Money
- Finance
- Avoiding floating point issues like `0.1 + 0.2`

They are not general-purpose math toolboxes.

Possible future rule:

> If financial precision becomes important, add `decimal.js` or `big.js`.

### `nerdamer`

Symbolic math library.

Good for:

- Equation solving
- Differentiation
- Integration
- Algebraic simplification

Not needed for normal business analytics.

### `numeric.js` / `ndarray` / `@stdlib`

More numerical/scientific computing oriented.

They may be useful for heavier scientific or numerical work, but they are harder and less likely to be written correctly by an LLM without specific instructions.

Not a good default for `deno-computer`.

## Final choice

For now:

```bash
deno add mathjs
```

Do not add `decimal.js`, `big.js`, `nerdamer`, `numeric.js`, `ndarray`, or `@stdlib` yet.

Add them later only when there is a concrete use case.
