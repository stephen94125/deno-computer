#!/usr/bin/env bash
set -euo pipefail

cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, ss, math, dfns, alasql } from "./context.ts";

const OrderRow = z.object({
  order_id: z.string(),
  order_date: z.string(),
  customer_id: z.string(),
  product: z.string(),
  category: z.string(),
  quantity: z.number(),
  unit_price: z.number(),
  discount: z.number(),
});

const rows = z.array(OrderRow).parse([
  { order_id: "O001", order_date: "2026-05-18", customer_id: "C001", product: "Apple", category: "Fruit", quantity: 10, unit_price: 100, discount: 0 },
  { order_id: "O002", order_date: "2026-05-18", customer_id: "C002", product: "Banana", category: "Fruit", quantity: 8, unit_price: 60, discount: 0 },
  { order_id: "O003", order_date: "2026-05-19", customer_id: "C003", product: "Mango", category: "Fruit", quantity: 5, unit_price: 300, discount: 100 },
  { order_id: "O004", order_date: "2026-05-19", customer_id: "C001", product: "Apple", category: "Fruit", quantity: 6, unit_price: 100, discount: 0 },
  { order_id: "O005", order_date: "2026-05-20", customer_id: "C004", product: "Pineapple", category: "Fruit", quantity: 4, unit_price: 220, discount: 80 },
  { order_id: "O006", order_date: "2026-05-20", customer_id: "C005", product: "Mango", category: "Fruit", quantity: 2, unit_price: 300, discount: 0 },
  { order_id: "O007", order_date: "2026-05-21", customer_id: "C006", product: "Apple", category: "Fruit", quantity: 20, unit_price: 100, discount: 200 },
  { order_id: "O008", order_date: "2026-05-21", customer_id: "C007", product: "Banana", category: "Fruit", quantity: 12, unit_price: 60, discount: 0 },
  { order_id: "O009", order_date: "2026-05-22", customer_id: "C008", product: "Mango", category: "Fruit", quantity: 8, unit_price: 300, discount: 0 },
  { order_id: "O010", order_date: "2026-05-22", customer_id: "C002", product: "Pineapple", category: "Fruit", quantity: 6, unit_price: 220, discount: 120 },
  { order_id: "O011", order_date: "2026-05-23", customer_id: "C009", product: "Apple", category: "Fruit", quantity: 7, unit_price: 100, discount: 0 },
  { order_id: "O012", order_date: "2026-05-23", customer_id: "C010", product: "Mango", category: "Fruit", quantity: 12, unit_price: 300, discount: 300 },
]);

const enrichedRows = rows.map((row) => {
  const gross_revenue = row.quantity * row.unit_price;
  const net_revenue = gross_revenue - row.discount;
  const discount_rate = gross_revenue === 0 ? 0 : row.discount / gross_revenue;

  return {
    ...row,
    gross_revenue,
    net_revenue,
    discount_rate,
  };
});

const productSummary = alasql(`
  SELECT
    product,
    category,
    SUM(quantity) AS total_quantity,
    SUM(gross_revenue) AS gross_revenue,
    SUM(discount) AS total_discount,
    SUM(net_revenue) AS net_revenue,
    SUM(net_revenue) / SUM(quantity) AS avg_net_unit_price,
    COUNT(*) AS order_lines
  FROM ?
  GROUP BY product, category
  ORDER BY net_revenue DESC
`, [enrichedRows]);

const dailySummary = alasql(`
  SELECT
    order_date,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(quantity) AS total_quantity,
    SUM(net_revenue) AS net_revenue
  FROM ?
  GROUP BY order_date
  ORDER BY order_date ASC
`, [enrichedRows]) as Array<{
  order_date: string;
  order_count: number;
  customer_count: number;
  total_quantity: number;
  net_revenue: number;
}>;

const dailyWithGrowth = dailySummary.map((row, index) => {
  const previous = dailySummary[index - 1];
  const revenue_growth_rate = previous
    ? (row.net_revenue - previous.net_revenue) / previous.net_revenue
    : null;

  return {
    ...row,
    revenue_growth_rate,
  };
});

const netRevenues = enrichedRows.map((row) => row.net_revenue);
const meanRevenue = ss.mean(netRevenues);
const revenueStd = ss.standardDeviation(netRevenues);

const anomalyOrders = enrichedRows
  .map((row) => ({
    ...row,
    z_score: revenueStd === 0 ? 0 : (row.net_revenue - meanRevenue) / revenueStd,
  }))
  .filter((row) => Math.abs(row.z_score) >= 1.5)
  .sort((a, b) => Math.abs(b.z_score) - Math.abs(a.z_score));

const totalRevenue = math.sum(netRevenues);
const totalQuantity = math.sum(enrichedRows.map((row) => row.quantity));
const totalDiscount = math.sum(enrichedRows.map((row) => row.discount));

const result = {
  generated_at: dfns.format(new Date(), "yyyy-MM-dd HH:mm:ss"),
  period: {
    start_date: dailySummary[0]?.order_date ?? null,
    end_date: dailySummary[dailySummary.length - 1]?.order_date ?? null,
    days: dailySummary.length,
  },
  overall: {
    total_orders: new Set(enrichedRows.map((row) => row.order_id)).size,
    total_customers: new Set(enrichedRows.map((row) => row.customer_id)).size,
    total_quantity: totalQuantity,
    gross_revenue: math.sum(enrichedRows.map((row) => row.gross_revenue)),
    total_discount: totalDiscount,
    net_revenue: totalRevenue,
    average_order_line_revenue: ss.mean(netRevenues),
    median_order_line_revenue: ss.median(netRevenues),
    revenue_standard_deviation: revenueStd,
    discount_rate: totalDiscount / math.sum(enrichedRows.map((row) => row.gross_revenue)),
  },
  product_summary: productSummary,
  daily_summary: dailyWithGrowth,
  anomaly_orders: anomalyOrders.map((row) => ({
    order_id: row.order_id,
    order_date: row.order_date,
    product: row.product,
    quantity: row.quantity,
    net_revenue: row.net_revenue,
    z_score: Number(row.z_score.toFixed(3)),
  })),
};

console.log(JSON.stringify(result, null, 2));
TS
