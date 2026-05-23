#!/usr/bin/env bash
set -euo pipefail

cat << 'TS' | ./skills/deno-computer/scripts/run-deno-computer.sh
import { z, csv } from "./context.ts";

const Product = z.object({
  product: z.string(),
  quantity: z.number(),
  revenue: z.number(),
});

const rows = z.array(Product).parse([
  { product: "Apple", quantity: 10, revenue: 1000 },
  { product: "Banana", quantity: 5, revenue: 300 },
]);

const csvText = csv.stringify(rows, {
  columns: ["product", "quantity", "revenue"],
});

console.log(JSON.stringify({
  valid: true,
  row_count: rows.length,
  csv: csvText,
}, null, 2));
TS
