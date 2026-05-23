#!/usr/bin/env bash
set -euo pipefail

cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, math, alasql, markdownTable } from "./context.ts";

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
`, [rows]) as Array<{
  product: string;
  total_quantity: number;
  total_revenue: number;
  avg_unit_price: number;
}>;

const table = markdownTable([
  ["Rank", "Product", "Quantity", "Revenue", "Avg Unit Price"],
  ...productSummary.map((row, index) => [
    String(index + 1),
    row.product,
    String(row.total_quantity),
    String(row.total_revenue),
    String(math.round(row.avg_unit_price, 2)),
  ]),
]);

console.log(table);
TS
