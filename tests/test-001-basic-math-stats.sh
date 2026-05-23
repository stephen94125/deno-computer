#!/usr/bin/env bash
set -euo pipefail

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
