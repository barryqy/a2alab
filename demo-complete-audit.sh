#!/bin/bash

set -euo pipefail

CI_MODE=0
JSON_MODE=0
SCAN_FAILURES=0

usage() {
  cat <<'EOF'
Usage: ./demo-complete-audit.sh [--ci-mode] [--json]

  --ci-mode   Skip the pauses and exit non-zero if risky cards are found
  --json      Print the final summary as JSON (implies --ci-mode)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --ci-mode)
      CI_MODE=1
      ;;
    --json)
      JSON_MODE=1
      CI_MODE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

print_line() {
  if [ "$JSON_MODE" -eq 0 ]; then
    echo "$1"
  fi
}

pause_if_needed() {
  if [ "$CI_MODE" -eq 0 ]; then
    echo ""
    read -p "Press Enter to continue..."
  fi
}

count_findings() {
  python3 - "$1" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.exists():
    print("0 0 0 0")
    raise SystemExit(0)

data = json.loads(path.read_text())
findings = data.get("findings", [])

high = 0
medium = 0
low = 0

for finding in findings:
    severity = (finding.get("severity") or "").upper()
    if severity == "HIGH":
        high += 1
    elif severity == "MEDIUM":
        medium += 1
    elif severity == "LOW":
        low += 1

print(len(findings), high, medium, low)
PY
}

classify_card() {
  local high_count="$1"
  local total_count="$2"

  if [ "$total_count" -eq 0 ]; then
    echo "passed"
    return
  fi

  if [ "$high_count" -gt 0 ]; then
    echo "critical"
    return
  fi

  echo "warning"
}

build_summary_json() {
  python3 - "$1" "$TOTAL" "$PASSED" "$WARNINGS" "$FAILED" \
    "$HIGH_COUNT" "$MEDIUM_COUNT" "$LOW_COUNT" "$SCAN_FAILURES" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

rows_path = Path(sys.argv[1])
total = int(sys.argv[2])
passed = int(sys.argv[3])
warnings = int(sys.argv[4])
failed = int(sys.argv[5])
high = int(sys.argv[6])
medium = int(sys.argv[7])
low = int(sys.argv[8])
scan_failures = int(sys.argv[9])

cards = []
reports = []

for line in rows_path.read_text().splitlines():
    name, status, findings, report_json = line.split("\t")
    cards.append(
        {
            "name": name,
            "status": status,
            "findings": int(findings),
        }
    )
    reports.append(report_json)

reports.append("reports/audit-summary.json")

summary = {
    "audit_date": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "total_scanned": total,
    "passed": passed,
    "warnings": warnings,
    "failed": failed,
    "high_findings": high,
    "medium_findings": medium,
    "low_findings": low,
    "scan_failures": scan_failures,
    "cards": cards,
    "reports": reports,
}

print(json.dumps(summary, indent=2))
PY
}

print_line ""
print_line "========================================"
print_line "Complete Security Audit Workflow"
print_line "========================================"
print_line ""
print_line "This demo scans every example card, saves the reports, and rolls them"
print_line "up into one summary you can reuse in CI or a larger review."

pause_if_needed

mkdir -p reports
rows_file="$(mktemp)"
trap 'rm -f "$rows_file"' EXIT

PASSED=0
WARNINGS=0
FAILED=0
TOTAL=0

HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

run_card_scan() {
  local card_path="$1"
  local card_name="$2"

  local report_json="reports/${card_name}-scan.json"
  local report_text="reports/${card_name}-scan.txt"

  TOTAL=$((TOTAL + 1))
  print_line ""
  print_line "Scanning: ${card_name}"

  set +e
  a2a-scanner scan-card "$card_path" --output "$report_json" \
    >"$report_text" 2>&1
  rc=$?
  set -e

  if [ "$rc" -gt 1 ] || [ ! -f "$report_json" ]; then
    print_line "  scan failed"
    SCAN_FAILURES=$((SCAN_FAILURES + 1))
    printf '%s\t%s\t%s\t%s\n' \
      "$card_name" "scan_failure" "0" "$report_json" >>"$rows_file"
    return
  fi

  read total high medium low <<EOF
$(count_findings "$report_json")
EOF

  HIGH_COUNT=$((HIGH_COUNT + high))
  MEDIUM_COUNT=$((MEDIUM_COUNT + medium))
  LOW_COUNT=$((LOW_COUNT + low))

  card_status="$(classify_card "$high" "$total")"
  printf '%s\t%s\t%s\t%s\n' \
    "$card_name" "$card_status" "$total" "$report_json" >>"$rows_file"

  case "$card_status" in
    passed)
      PASSED=$((PASSED + 1))
      print_line "  status: passed (${total} findings)"
      ;;
    critical)
      FAILED=$((FAILED + 1))
      print_line "  status: failed (${high} HIGH severity findings)"
      ;;
    *)
      WARNINGS=$((WARNINGS + 1))
      print_line "  status: warning (${medium} MEDIUM, ${low} LOW)"
      ;;
  esac

  print_line "  saved: ${report_json}"
}

run_card_scan "examples/safe-agent-card.json" "safe-agent-card"
run_card_scan "examples/malicious-agent-card.json" "malicious-agent-card"
run_card_scan "examples/mixed-security-agent.json" "mixed-security-agent"
run_card_scan "examples/prompt-injection-agent.json" "prompt-injection-agent"
run_card_scan "examples/data-exfil-agent.json" "data-exfil-agent"

summary_json="$(build_summary_json "$rows_file")"
printf '%s\n' "$summary_json" > reports/audit-summary.json

if [ "$JSON_MODE" -eq 1 ]; then
  printf '%s\n' "$summary_json"
else
  PASSED_PCT=$(( PASSED * 100 / TOTAL ))
  WARNINGS_PCT=$(( WARNINGS * 100 / TOTAL ))
  FAILED_PCT=$(( FAILED * 100 / TOTAL ))

  print_line ""
  print_line "========================================"
  print_line "Audit Summary"
  print_line "========================================"
  print_line ""
  print_line "Total cards scanned: $TOTAL"
  print_line "Passed: $PASSED ($PASSED_PCT%)"
  print_line "Warnings: $WARNINGS ($WARNINGS_PCT%)"
  print_line "Failed: $FAILED ($FAILED_PCT%)"
  print_line ""
  print_line "Severity totals:"
  print_line "  HIGH: $HIGH_COUNT"
  print_line "  MEDIUM: $MEDIUM_COUNT"
  print_line "  LOW: $LOW_COUNT"
  print_line ""
  print_line "Reports:"
  print_line "  reports/safe-agent-card-scan.json"
  print_line "  reports/malicious-agent-card-scan.json"
  print_line "  reports/mixed-security-agent-scan.json"
  print_line "  reports/prompt-injection-agent-scan.json"
  print_line "  reports/data-exfil-agent-scan.json"
  print_line "  reports/audit-summary.json"
fi

if [ "$FAILED" -gt 0 ] || [ "$SCAN_FAILURES" -gt 0 ]; then
  exit 1
fi
