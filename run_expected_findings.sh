#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./run_expected_findings.sh card <agent-card.json> <expected-count|any> [scanner args...]
  ./run_expected_findings.sh endpoint <url> <expected-count|any> [scanner args...]

Runs a scanner command that is expected to find issues. The A2A Scanner may
return exit code 1 when findings are present; this helper treats that as a
successful lab outcome as long as the output matches the expected findings.
EOF
}

if [ "$#" -lt 3 ]; then
  usage >&2
  exit 2
fi

mode="$1"
target="$2"
expected_count="$3"
shift 3

tmp_out="$(mktemp)"
trap 'rm -f "$tmp_out"' EXIT

case "$mode" in
  card)
    cmd=(a2a-scanner scan-card "$target" "$@")
    ;;
  endpoint)
    cmd=(a2a-scanner --dev scan-endpoint "$target" "$@")
    ;;
  *)
    echo "Unknown scan mode: $mode" >&2
    usage >&2
    exit 2
    ;;
esac

set +e
"${cmd[@]}" | tee "$tmp_out"
scan_rc=${PIPESTATUS[0]}
set -e

if [ "$scan_rc" -gt 1 ]; then
  echo "Scanner failed unexpectedly with exit code $scan_rc" >&2
  exit "$scan_rc"
fi

if [ "$expected_count" = "any" ]; then
  echo "Verified scan completed with acceptable exit code $scan_rc."
  exit 0
fi

actual_count="$(
  python3 - "$tmp_out" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
match = re.search(r"Total Findings:\s*(\d+)", text)
print(match.group(1) if match else "")
PY
)"

if [ -z "$actual_count" ]; then
  echo "Could not find a Total Findings line in scanner output." >&2
  exit 1
fi

if [ "$actual_count" != "$expected_count" ]; then
  echo "Expected $expected_count findings, but scanner reported $actual_count." >&2
  exit 1
fi

echo "Verified expected findings: $actual_count."
