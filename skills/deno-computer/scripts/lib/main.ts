import { z, ss, math, dfns, csv, alasql } from "./context.ts";

const rows = [
  { product: "A", revenue: 100 },
  { product: "B", revenue: 200 },
];

const result = alasql(`
  SELECT product, SUM(revenue) AS total_revenue
  FROM ?
  GROUP BY product
  ORDER BY total_revenue DESC
`, [rows]);

console.log(JSON.stringify({
  generated_at: dfns.format(new Date(), "yyyy-MM-dd HH:mm:ss"),
  average_revenue: ss.mean(rows.map((r) => r.revenue)),
  result,
}, null, 2));
