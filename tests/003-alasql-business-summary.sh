#!/usr/bin/env bash
set -euo pipefail

cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, ss, dfns, alasql } from "./context.ts";

const OrderRow = z.object({
  product: z.string(),
  quantity: z.number(),
  revenue: z.number(),
  order_date: z.string(),
});

const rows = z.array(OrderRow).parse([
  { product: "Apple", quantity: 10, revenue: 1000, order_date: "2026-05-20" },
  { product: "Apple", quantity: 5, revenue: 500, order_date: "2026-05-21" },
  { product: "Banana", quantity: 8, revenue: 480, order_date: "2026-05-21" },
  { product: "Mango", quantity: 3, revenue: 900, order_date: "2026-05-22" },
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
  generated_at: dfns.format(new Date(), "yyyy-MM-dd HH:mm:ss"),
  total_revenue: revenues.reduce((sum, value) => sum + value, 0),
  average_order_revenue: ss.mean(revenues),
  product_summary: productSummary,
}, null, 2));
TS
