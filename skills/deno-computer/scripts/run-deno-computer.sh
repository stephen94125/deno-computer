#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_CODE="$SCRIPT_DIR/main.ts"
DENO_CONFIG="$SCRIPT_DIR/deno.json"

cat > "$USER_CODE"

cd "$SCRIPT_DIR"

CHECK_OUTPUT="$(deno check --config "$DENO_CONFIG" "$USER_CODE" 2>&1)" || {
  echo "$CHECK_OUTPUT" >&2
  exit 1
}

deno run \
  --config "$DENO_CONFIG" \
  --no-check \
  --no-prompt \
  "$USER_CODE"
