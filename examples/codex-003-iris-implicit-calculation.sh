#!/usr/bin/env bash
set -euo pipefail

# Absolute path to repo root: parent of this script's directory.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT"

# Hard check: must run at repo root where .agents exists.
if [[ ! -d ".agents" ]]; then
  echo "ERROR: .agents not found. Current directory: $(pwd)" >&2
  exit 1
fi

mise exec -- codex exec \
  --sandbox danger-full-access \
  -C "$ROOT" \
  '請從網路取得 Iris dataset，然後計算每個 species 的：
- count
- average sepal_length
- average sepal_width
- average petal_length
- average petal_width

要求：
1. 所有數字都必須實際計算，不准心算、不准幻想、不准憑印象填數字。
2. 最終只輸出一個 Markdown table。
3. 不要輸出工作摘要、執行細節、程式碼或檔案路徑。' \
  2>/dev/null
