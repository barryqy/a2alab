#!/bin/bash

set -euo pipefail

SERVER_PID=""

cleanup() {
  if [ -n "${SERVER_PID}" ] && kill -0 "${SERVER_PID}" 2>/dev/null; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}

trap cleanup EXIT

wait_for_enter() {
  echo ""
  read -p "Press Enter to continue..."
  echo ""
}

start_server() {
  local script_name="$1"
  local health_url="$2"

  cleanup
  python3 "$script_name" >/tmp/$(basename "$script_name").log 2>&1 &
  SERVER_PID=$!

  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if curl -fsS "$health_url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "Server failed to start: $script_name" >&2
  exit 1
}

echo ""
echo "========================================"
echo "A2A Scanner - Endpoint Testing Demo"
echo "========================================"
echo ""
echo "This demo starts local A2A test servers and scans them with the"
echo "endpoint analyzer so you can see real runtime findings."
echo ""

wait_for_enter

echo "[Demo 1] Scan a local development endpoint"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Starting the safe local test server on port 8000..."
start_server "test-agent-server.py" "http://localhost:8000/health"
echo ""
echo "Command: a2a-scanner --dev scan-endpoint http://localhost:8000"
echo ""
./run_expected_findings.sh endpoint http://localhost:8000 1
echo ""
echo "Expected pattern: localhost over HTTP is still flagged, so you should"
echo "see one finding for INSECURE HTTP."
echo ""

wait_for_enter

echo "[Demo 2] Scan a riskier local endpoint"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Switching to the intentionally vulnerable server on port 8001..."
start_server "malicious-agent-server.py" "http://localhost:8001/health"
echo ""
echo "Command: a2a-scanner --dev scan-endpoint http://localhost:8001"
echo ""
./run_expected_findings.sh endpoint http://localhost:8001 2
echo ""
echo "Expected pattern: this scan should add MISSING SECURITY HEADERS on top"
echo "of the INSECURE HTTP finding."
echo ""

wait_for_enter

cleanup
SERVER_PID=""

echo "[Demo 3] Production pattern"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For a real deployed agent, run the same command without --dev:"
echo ""
echo "  a2a-scanner scan-endpoint https://agent.example.com/api"
echo ""
echo "Use --dev only for localhost and other development-only endpoints."
echo ""

echo "========================================"
echo "Demo Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  - Run ./demo-complete-audit.sh for a full card audit"
echo "  - Try scanning your own A2A endpoint with scan-endpoint"
