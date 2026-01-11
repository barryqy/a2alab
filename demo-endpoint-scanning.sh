#!/bin/bash

# A2A Scanner Lab - Endpoint Security Testing Demo
# This script demonstrates live endpoint scanning with A2A Scanner

echo ""
echo "========================================"
echo "A2A Scanner - Endpoint Testing Demo"
echo "========================================"
echo ""
echo "This demo shows how to test running A2A agent endpoints for security."
echo ""

# Function to wait for user input
wait_for_enter() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

# Introduction
echo "The Endpoint Analyzer performs dynamic security testing:"
echo "  • HTTPS enforcement"
echo "  • Security headers validation"
echo "  • Agent card presence checking"
echo "  • URL consistency verification"
echo "  • Health endpoint validation"
echo ""

wait_for_enter

# Demo 1: Endpoint Analyzer Overview
echo "[Demo 1] Understanding Endpoint Security Testing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The endpoint analyzer tests running agents for:"
echo ""
echo "1. Protocol Security"
echo "   ✓ Uses HTTPS (not HTTP)"
echo "   ✗ Flags HTTP as HIGH severity"
echo ""
echo "2. Security Headers"
echo "   ✓ X-Content-Type-Options: nosniff"
echo "   ✓ X-Frame-Options: DENY or SAMEORIGIN"
echo "   ✓ Strict-Transport-Security (HSTS)"
echo ""
echo "3. Agent Card"
echo "   ✓ Card exists at /.well-known/agent-card.json"
echo "   ✓ Card URL matches endpoint"
echo ""
echo "4. Health Monitoring"
echo "   ✓ /health or /healthz endpoint present"
echo ""

wait_for_enter

# Demo 2: Scanning a Local Development Endpoint
echo "[Demo 2] Scanning Local Development Endpoint"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "When testing localhost or development endpoints, use --dev flag:"
echo ""
echo "Command: a2a-scanner --dev scan-endpoint http://localhost:8000"
echo ""
echo "Note: --dev flag allows:"
echo "  • Localhost URLs"
echo "  • Private IP addresses"
echo "  • HTTP (non-HTTPS) connections"
echo "  • Self-signed SSL certificates"
echo ""
echo "⚠️  WARNING: Never use --dev in production!"
echo ""
echo "For this demo, we'll skip actual endpoint scanning since no agent is running."
echo "In a real scenario, you would:"
echo "  1. Start an A2A agent locally"
echo "  2. Run: a2a-scanner --dev scan-endpoint http://localhost:8000"
echo "  3. Review security findings"
echo ""

wait_for_enter

# Demo 3: Production Endpoint Scanning Pattern
echo "[Demo 3] Production Endpoint Scanning"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For production agents, scan without --dev flag:"
echo ""
echo "Command: a2a-scanner scan-endpoint https://agent.example.com/api"
echo ""
echo "Expected checks:"
echo "  ✓ HTTPS Protocol: PASSED (uses secure protocol)"
echo "  ⚠️  Security Headers: PARTIAL (some headers missing)"
echo "  ✓ Agent Card: PASSED (found at /.well-known/agent-card.json)"
echo "  ✓ URL Consistency: PASSED (card URL matches endpoint)"
echo "  ⚠️  Health Endpoint: WARNING (no /health found)"
echo ""
echo "Common issues detected:"
echo "  • Missing security headers (MEDIUM severity)"
echo "  • HTTP instead of HTTPS (HIGH severity)"
echo "  • No agent card present (MEDIUM severity)"
echo "  • URL mismatch (potential impersonation - HIGH severity)"
echo ""

wait_for_enter

# Demo 4: Batch Endpoint Scanning
echo "[Demo 4] Batch Endpoint Scanning"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For monitoring multiple production agents:"
echo ""
echo "Example script:"
cat << 'EOF'
#!/bin/bash
# scan-all-endpoints.sh

ENDPOINTS=(
    "https://agent1.example.com/api"
    "https://agent2.example.com/api"
    "https://agent3.example.com/api"
)

for endpoint in "${ENDPOINTS[@]}"; do
    echo "Scanning: $endpoint"
    a2a-scanner scan-endpoint "$endpoint" \
        --output "reports/$(basename $endpoint)-scan.json"
done
EOF
echo ""

wait_for_enter

# Demo 5: CI/CD Integration
echo "[Demo 5] CI/CD Integration for Endpoint Testing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Example GitHub Actions workflow:"
echo ""
cat << 'EOF'
name: A2A Endpoint Security Scan

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  scan-endpoints:
    runs-on: ubuntu-latest
    steps:
      - name: Install A2A Scanner
        run: |
          curl -LsSf https://astral.sh/uv/install.sh | sh
          uv tool install cisco-ai-a2a-scanner
      
      - name: Scan Production Endpoints
        run: |
          a2a-scanner scan-endpoint ${{ secrets.PROD_AGENT_URL }} \
            --output scan-results.json
      
      - name: Check for HIGH severity
        run: |
          if grep -q '"severity": "HIGH"' scan-results.json; then
            echo "HIGH severity threats found!"
            exit 1
          fi
EOF
echo ""

wait_for_enter

# Demo 6: Continuous Monitoring
echo "[Demo 6] Continuous Monitoring Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For production monitoring, scan endpoints periodically:"
echo ""
echo "Cron job example (daily at 2 AM):"
echo "0 2 * * * /path/to/scan-endpoints.sh >> /var/log/a2a-scanner.log 2>&1"
echo ""
echo "Monitoring script should:"
echo "  1. Scan all production agent endpoints"
echo "  2. Log results with timestamps"
echo "  3. Alert on HIGH severity findings"
echo "  4. Generate weekly summary reports"
echo ""

wait_for_enter

# Summary
echo ""
echo "========================================"
echo "Demo Complete!"
echo "========================================"
echo ""
echo "You've learned about:"
echo "  ✓ Endpoint analyzer capabilities"
echo "  ✓ Development vs production scanning"
echo "  ✓ Batch endpoint testing"
echo "  ✓ CI/CD integration patterns"
echo "  ✓ Continuous monitoring setup"
echo ""
echo "Key takeaways:"
echo "  • Use --dev only for localhost/development testing"
echo "  • Scan endpoints regularly in production"
echo "  • Integrate into CI/CD for pre-deployment validation"
echo "  • Monitor for HTTPS, security headers, and agent cards"
echo ""
echo "Next steps:"
echo "  • Set up a test A2A agent locally"
echo "  • Practice scanning with --dev flag"
echo "  • Run: bash demo-complete-audit.sh for full audit workflow"
echo ""
