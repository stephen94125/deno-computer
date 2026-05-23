#!/usr/bin/env bash
set -euo pipefail

# Absolute path to repo root: parent of this script's directory.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT"

if [[ ! -d ".agents" ]]; then
  echo "ERROR: .agents not found. Current directory: $(pwd)" >&2
  exit 1
fi

mise exec -- codex exec \
  --sandbox danger-full-access \
  -C "$ROOT" \
  '使用 deno-computer 這個 skill。

請從網路取得 Gapminder dataset，選取資料中最新年份，然後用 deno-computer 計算每個 continent 的：
- country_count
- average lifeExp
- average gdpPercap
- total pop

要求：
1. 所有數字都必須透過 deno-computer 執行計算，不准自己心算或幻想數字。
2. deno-computer 只能用規定的 heredoc pipe 方式呼叫。
3. 最終只輸出 CSV，不要輸出 Markdown table。
4. 不要輸出工作摘要、執行細節、程式碼或檔案路徑。' \
  2>/dev/null
