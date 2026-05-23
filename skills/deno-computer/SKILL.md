---
name: deno-computer
description: "Use this skill for any arithmetic, statistics, table aggregation, date calculation, CSV output, Markdown-table output, business-analysis computation, or data-derived number. If this skill is available and the task involves numbers, do not invent or estimate results from memory. Read this skill and use the Deno computer. When numeric accuracy matters, it is forbidden to hallucinate numbers instead of executing the calculator."
---

# Deno Computer Skill

## Core Capability

Use this skill as a safe TypeScript/Deno calculator for business analysis.

The purpose is not to ask the LLM to mentally calculate numbers. The purpose is:

```txt
User asks for numeric / tabular / business-analysis result
→ write TypeScript
→ execute through the required Deno computer gateway
→ use the actual stdout result
→ explain or summarize the computed result
```

Use this skill whenever a task involves:

- arithmetic
- statistics
- averages / medians / standard deviation
- growth rates
- rankings
- grouping / aggregation
- deduplication
- date calculations
- CSV output
- Markdown table output
- business-analysis summaries
- any data-derived number

If this skill is available and the task involves numeric computation, **do not produce numbers by imagination**.

---

# Installed Libraries

Generated TypeScript can import the prepared libraries from:

```ts
import {
  z,
  ss,
  math,
  dfns,
  csv,
  alasql,
  markdownTable,
} from "./context.ts";
```

## Library Map

| Export | Library | Use for |
|---|---|---|
| `z` | `zod` | Runtime validation and schema checking |
| `ss` | `simple-statistics` | Mean, median, standard deviation, quantile, correlation, simple regression |
| `math` | `mathjs` | General math helpers, rounding, sums, formulas, light matrix-like operations |
| `dfns` | `date-fns` | Date formatting and date arithmetic |
| `csv` | `@std/csv` | CSV parse/stringify as text only |
| `alasql` | `alasql` | SQL-style grouping, aggregation, ordering, joins, deduplication |
| `markdownTable` | `markdown-table` | Convert homogeneous rows into Markdown tables |

## Output Format Choice

Default output preference:

```txt
Markdown table > CSV > JSON
```

Use:

- **Markdown table** by default when the result is homogeneous, flat, and table-shaped.
- **CSV** when the result is homogeneous and likely to be copied into a spreadsheet or passed to another tool.
- **JSON** when the result is heterogeneous, nested, or needs to preserve machine-readable structure.

If the user does not specify an output format:

```txt
homogeneous table-like result → Markdown table
heterogeneous / nested result → JSON
spreadsheet-oriented flat data → CSV
```

---

# Hard Execution Boundary

## Required Execution Gateway

All computation for this skill **MUST** be executed through:

```txt
scripts/run-deno-computer.sh
```

Do not compute, transform, aggregate, summarize, or derive numeric results with any other tool.

Do not run TypeScript directly with `deno run`.

Do not manually edit, patch, or overwrite `scripts/main.ts`.

`scripts/main.ts` is an internal scratch file owned by `run-deno-computer.sh`.

The only valid execution pattern is:

```txt
TypeScript code
→ pipe into scripts/run-deno-computer.sh
→ let the script typecheck and execute it
```

## Required Bash / Heredoc Form

When using a bash shell tool, execute Deno Computer code only with this heredoc pipe shape:

```bash
cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { ss, math, dfns } from "./context.ts";

const values = [100, 200, 300, 400];

console.log(JSON.stringify({
  generated_at: dfns.format(new Date(), "yyyy-MM-dd HH:mm:ss"),
  sum: math.sum(values),
  mean: ss.mean(values),
  median: ss.median(values),
  standard_deviation: ss.standardDeviation(values),
}, null, 2));
TS
```

Rules:

- The heredoc delimiter must be quoted as `'TS'`.
- The TypeScript code goes between `cat << 'TS'` and the final `TS`.
- The pipe target must be `./skills/deno-computer/scripts/run-deno-computer.sh` when called from repo root.
- If already inside the skill directory, use `scripts/run-deno-computer.sh`.
- Do not replace this with direct `deno run`.
- Do not replace this with `echo "...code..."`.
- Do not write directly to `scripts/main.ts`.
- Do not use shell heredoc inside the TypeScript code itself.

---

# Do Not

Do not:

- Do not mentally calculate non-trivial numbers.
- Do not invent numeric results.
- Do not compute, transform, aggregate, summarize, or derive numeric results with tools other than `scripts/run-deno-computer.sh`.
- Do not use this skill without executing the TypeScript through `scripts/run-deno-computer.sh`.
- Do not use direct `deno run`, `deno check`, or `deno task run` for skill execution.
- Do not bypass `scripts/run-deno-computer.sh`.
- Do not edit `scripts/main.ts` directly.
- Do not import packages directly from npm/jsr in generated code.
- Do not use imports other than `./context.ts` unless debugging the skill itself.
- Do not read files.
- Do not write files.
- Do not access network.
- Do not access environment variables.
- Do not call subprocesses.
- Do not use `Deno.readTextFile`, `Deno.writeTextFile`, `Deno.open`, `Deno.env`, `Deno.Command`, or `fetch`.
- Do not install new dependencies during task execution.
- Do not output huge raw data unless explicitly debugging.

This skill is a calculator, not a shell, crawler, file processor, or external API client.

---

# Preferred Workflow

For numeric or business-analysis tasks:

```txt
1. Decide whether the computation is arithmetic, statistics, table aggregation, date calculation, CSV, or Markdown table.
2. Write a small TypeScript snippet.
3. Import allowed tools from ./context.ts.
4. Validate input data with zod when data shape matters.
5. Use AlaSQL for naturally SQL-like grouping, aggregation, joins, ordering, and deduplication.
6. Use clear TypeScript loops when the transformation is very small and easier to read than SQL.
7. Use simple-statistics for statistical calculations.
8. Use mathjs for general math and rounding.
9. Use date-fns for date formatting/arithmetic.
10. Print the final result using console.log.
11. Use the actual stdout result in the final answer.
```

For uncertain data shape, first inspect or normalize the data in a small bounded snippet. Do not assume deeply nested fields.

---

# Common Examples

## Example 1: Basic math and statistics

```bash
cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { ss, math, dfns } from "./context.ts";

const values = [100, 200, 300, 400];

const result = {
  generated_at: dfns.format(new Date(), "yyyy-MM-dd HH:mm:ss"),
  count: values.length,
  sum: math.sum(values),
  mean: ss.mean(values),
  median: ss.median(values),
  standard_deviation: ss.standardDeviation(values),
};

console.log(JSON.stringify(result, null, 2));
TS
```

## Example 2: Validate rows, aggregate with SQL, output JSON

```bash
cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, ss, math, alasql } from "./context.ts";

const OrderRow = z.object({
  product: z.string(),
  quantity: z.number(),
  revenue: z.number(),
});

const rows = z.array(OrderRow).parse([
  { product: "Apple", quantity: 43, revenue: 4100 },
  { product: "Mango", quantity: 27, revenue: 7700 },
  { product: "Pineapple", quantity: 10, revenue: 2000 },
  { product: "Banana", quantity: 20, revenue: 1200 },
]);

const productSummary = alasql(`
  SELECT
    product,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    SUM(revenue) / SUM(quantity) AS avg_unit_price
  FROM ?
  GROUP BY product
  ORDER BY total_revenue DESC
`, [rows]);

const revenues = rows.map((row) => row.revenue);

console.log(JSON.stringify({
  total_revenue: math.sum(revenues),
  average_revenue: ss.mean(revenues),
  product_summary: productSummary,
}, null, 2));
TS
```

## Example 3: Print CSV text

```bash
cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, math, alasql, csv } from "./context.ts";

const ProductRow = z.object({
  product: z.string(),
  quantity: z.number(),
  revenue: z.number(),
});

const rows = z.array(ProductRow).parse([
  { product: "Apple", quantity: 43, revenue: 4100 },
  { product: "Mango", quantity: 27, revenue: 7700 },
  { product: "Pineapple", quantity: 10, revenue: 2000 },
  { product: "Banana", quantity: 20, revenue: 1200 },
]);

const summary = alasql(`
  SELECT
    product,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    SUM(revenue) / SUM(quantity) AS avg_unit_price
  FROM ?
  GROUP BY product
  ORDER BY total_revenue DESC
`, [rows]) as Array<{
  product: string;
  total_quantity: number;
  total_revenue: number;
  avg_unit_price: number;
}>;

const csvRows = summary.map((row, index) => ({
  rank: index + 1,
  product: row.product,
  total_quantity: row.total_quantity,
  total_revenue: row.total_revenue,
  avg_unit_price: math.round(row.avg_unit_price, 2),
}));

console.log(csv.stringify(csvRows, {
  columns: [
    "rank",
    "product",
    "total_quantity",
    "total_revenue",
    "avg_unit_price",
  ],
}));
TS
```

## Example 4: Print Markdown table

```bash
cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, math, alasql, markdownTable } from "./context.ts";

const ProductRow = z.object({
  product: z.string(),
  quantity: z.number(),
  revenue: z.number(),
});

const rows = z.array(ProductRow).parse([
  { product: "Apple", quantity: 43, revenue: 4100 },
  { product: "Mango", quantity: 27, revenue: 7700 },
  { product: "Pineapple", quantity: 10, revenue: 2000 },
  { product: "Banana", quantity: 20, revenue: 1200 },
]);

const summary = alasql(`
  SELECT
    product,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    SUM(revenue) / SUM(quantity) AS avg_unit_price
  FROM ?
  GROUP BY product
  ORDER BY total_revenue DESC
`, [rows]) as Array<{
  product: string;
  total_quantity: number;
  total_revenue: number;
  avg_unit_price: number;
}>;

const table = markdownTable([
  ["Rank", "Product", "Quantity", "Revenue", "Avg Unit Price"],
  ...summary.map((row, index) => [
    String(index + 1),
    row.product,
    String(row.total_quantity),
    String(row.total_revenue),
    String(math.round(row.avg_unit_price, 2)),
  ]),
]);

console.log(table);
TS
```

---

# Usage Notes

## AlaSQL

For table-shaped aggregation, prefer `alasql` when the query is naturally SQL-like.

Good use cases:

- `GROUP BY`
- `SUM`
- `COUNT`
- `COUNT(DISTINCT ...)`
- `ORDER BY`
- `JOIN`
- `SELECT DISTINCT`
- top-N summaries

For very small transformations, clear TypeScript loops are acceptable.

The hard rule is not "must use libraries." The hard rule is: computed numbers must come from code executed through `scripts/run-deno-computer.sh`, not from imagination.

## simple-statistics

Use `ss` for statistical calculations:

```ts
ss.mean(values)
ss.median(values)
ss.standardDeviation(values)
ss.quantile(values, 0.9)
ss.sampleCorrelation(xs, ys)
```

## mathjs

Use `math` for general math helpers and rounding:

```ts
math.sum(values)
math.round(value, 2)
```

Do not add matrix-specific libraries by default. If serious linear algebra is needed, reconsider the tool choice.

## date-fns

Use `dfns` for date formatting and date arithmetic:

```ts
dfns.format(new Date(), "yyyy-MM-dd HH:mm:ss")
dfns.addDays(new Date(), 7)
dfns.subDays(new Date(), 1)
```

## CSV

Use `csv.stringify` or `csv.parse` only as text conversion.

Do not save CSV files.

## Markdown Tables

Use `markdownTable` for homogeneous flat summaries that the user or another LLM should read quickly.

Do not manually hand-build Markdown table alignment unless necessary.

---

# Numeric Accuracy Rule

If the answer contains a computed number, make sure the number came from executed code unless it is trivial mental arithmetic.

Bad:

```txt
"The average is probably around 700."
```

Good:

```txt
Run Deno Computer → use stdout → answer with computed result.
```

For business reports, prefer computed output over verbal estimation.

---

# Failure Handling

If type checking fails:

1. Read the TypeScript error.
2. Fix imports, types, or function names.
3. Re-run through `scripts/run-deno-computer.sh`.

If runtime fails:

1. Inspect the error.
2. Reduce the snippet.
3. Validate data shape with `zod`.
4. Re-run.

Do not bypass the execution gateway to debug faster.

---

# Example Files

See local examples if available:

```txt
examples/001-basic-math-stats.sh
examples/002-zod-csv.sh
examples/003-alasql-business-summary.sh
examples/004-complex-business-analysis.sh
examples/005-csv-output.sh
examples/006-markdown-table-output.sh
```

These examples demonstrate the expected invocation style. Follow the same pattern.
