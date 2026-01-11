#!/bin/bash

# A2A Scanner Lab - Complete Security Audit Demo
# This script demonstrates a comprehensive security audit workflow

echo ""
echo "========================================"
echo "Complete Security Audit Workflow"
echo "========================================"
echo ""
echo "This demo shows a full security audit process for A2A agents."
echo ""

# Function to wait for user input
wait_for_enter() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

# Create reports directory
mkdir -p reports

# Introduction
echo "A complete security audit includes:"
echo "  1. Batch scanning of all agent cards"
echo "  2. Multi-analyzer coverage"
echo "  3. Aggregate statistics"
echo "  4. Report generation"
echo "  5. Threshold-based pass/fail"
echo ""

wait_for_enter

# Step 1: Batch Scanning
echo "[Step 1] Scanning All Agent Cards"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASSED=0
WARNINGS=0
FAILED=0
TOTAL=0

HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

for card in examples/*.json; do
    TOTAL=$((TOTAL + 1))
    agent_name=$(basename "$card" .json)
    
    echo "Scanning: $card"
    
    # Scan with multiple analyzers and save results
    a2a-scanner scan-card "$card" --analyzers yara,spec,heuristic \
        --output "reports/${agent_name}-scan.json" > /dev/null 2>&1
    
    # Check exit code
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✓ Status: PASSED (0 threats)"
        PASSED=$((PASSED + 1))
    elif [ $EXIT_CODE -eq 1 ]; then
        # Check severity
        if grep -q '"severity": "HIGH"' "reports/${agent_name}-scan.json" 2>/dev/null; then
            echo "✗ Status: FAILED (HIGH severity threats found)"
            FAILED=$((FAILED + 1))
            
            # Count threats
            HIGH=$(grep -c '"severity": "HIGH"' "reports/${agent_name}-scan.json" 2>/dev/null || echo 0)
            MEDIUM=$(grep -c '"severity": "MEDIUM"' "reports/${agent_name}-scan.json" 2>/dev/null || echo 0)
            LOW=$(grep -c '"severity": "LOW"' "reports/${agent_name}-scan.json" 2>/dev/null || echo 0)
            
            HIGH_COUNT=$((HIGH_COUNT + HIGH))
            MEDIUM_COUNT=$((MEDIUM_COUNT + MEDIUM))
            LOW_COUNT=$((LOW_COUNT + LOW))
            
            echo "  → $HIGH HIGH, $MEDIUM MEDIUM, $LOW LOW"
        else
            echo "⚠️  Status: WARNING (MEDIUM/LOW severity only)"
            WARNINGS=$((WARNINGS + 1))
            
            # Count threats
            MEDIUM=$(grep -c '"severity": "MEDIUM"' "reports/${agent_name}-scan.json" 2>/dev/null || echo 0)
            LOW=$(grep -c '"severity": "LOW"' "reports/${agent_name}-scan.json" 2>/dev/null || echo 0)
            
            MEDIUM_COUNT=$((MEDIUM_COUNT + MEDIUM))
            LOW_COUNT=$((LOW_COUNT + LOW))
            
            echo "  → $MEDIUM MEDIUM, $LOW LOW"
        fi
    fi
    
    echo ""
done

wait_for_enter

# Step 2: Summary Report
echo "[Step 2] Generating Summary Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Calculate percentages
PASSED_PCT=$(( PASSED * 100 / TOTAL ))
WARNINGS_PCT=$(( WARNINGS * 100 / TOTAL ))
FAILED_PCT=$(( FAILED * 100 / TOTAL ))

# Display summary
cat << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Audit Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Agents Scanned: $TOTAL
✓ Passed: $PASSED ($PASSED_PCT%)
⚠️  Warnings: $WARNINGS ($WARNINGS_PCT%)
✗ Failed: $FAILED ($FAILED_PCT%)

Threat Severity Breakdown:
  🚨 HIGH: $HIGH_COUNT findings
  ⚠️  MEDIUM: $MEDIUM_COUNT findings
  ℹ️  LOW: $LOW_COUNT findings

Top Threat Categories:
EOF

# Count threat types from all reports
echo "  1. Prompt Injection: $(grep -h "prompt" reports/*.json 2>/dev/null | wc -l | tr -d ' ') instances"
echo "  2. Data Exfiltration: $(grep -h "exfil\|webhook\|external" reports/*.json 2>/dev/null | wc -l | tr -d ' ') instances"
echo "  3. Agent Impersonation: $(grep -h "imperson" reports/*.json 2>/dev/null | wc -l | tr -d ' ') instances"
echo "  4. Capability Abuse: $(grep -h "capability\|execute" reports/*.json 2>/dev/null | wc -l | tr -d ' ') instances"
echo "  5. Insecure Endpoints: $(grep -h "http://" reports/*.json 2>/dev/null | wc -l | tr -d ' ') instances"

echo ""
echo "Detailed reports saved to:"
for report in reports/*-scan.json; do
    echo "  • $report"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

wait_for_enter

# Step 3: Create Summary JSON
echo "[Step 3] Creating Machine-Readable Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > reports/audit-summary.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "total_scanned": $TOTAL,
  "results": {
    "passed": $PASSED,
    "warnings": $WARNINGS,
    "failed": $FAILED
  },
  "severity_counts": {
    "high": $HIGH_COUNT,
    "medium": $MEDIUM_COUNT,
    "low": $LOW_COUNT
  },
  "pass_rate": $PASSED_PCT,
  "reports_directory": "reports/"
}
EOF

echo "✓ Summary saved to: reports/audit-summary.json"
echo ""
cat reports/audit-summary.json
echo ""

wait_for_enter

# Step 4: CI/CD Integration Example
echo "[Step 4] CI/CD Integration Pattern"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For CI/CD pipelines, set thresholds for pass/fail:"
echo ""

# Example threshold logic
THRESHOLD_HIGH=0  # Fail if any HIGH severity
THRESHOLD_FAILED=0  # Fail if any agents fail

if [ $HIGH_COUNT -gt $THRESHOLD_HIGH ]; then
    echo "❌ AUDIT FAILED: $HIGH_COUNT HIGH severity threats detected (threshold: $THRESHOLD_HIGH)"
    echo "   Build should be blocked!"
    EXIT_STATUS=1
elif [ $FAILED -gt $THRESHOLD_FAILED ]; then
    echo "❌ AUDIT FAILED: $FAILED agents failed (threshold: $THRESHOLD_FAILED)"
    echo "   Build should be blocked!"
    EXIT_STATUS=1
else
    echo "✅ AUDIT PASSED: No HIGH severity threats, all thresholds met"
    echo "   Build can proceed!"
    EXIT_STATUS=0
fi

echo ""
echo "Example GitHub Actions usage:"
cat << 'YAML'
name: Security Audit

on: [push, pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install A2A Scanner
        run: |
          curl -LsSf https://astral.sh/uv/install.sh | sh
          uv tool install cisco-ai-a2a-scanner
      
      - name: Run Security Audit
        run: bash demo-complete-audit.sh
      
      - name: Upload Reports
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: reports/
YAML
echo ""

wait_for_enter

# Step 5: Best Practices Summary
echo "[Step 5] Security Audit Best Practices"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Regular Scanning"
echo "   • Scan before every deployment"
echo "   • Run daily/weekly audits of production agents"
echo "   • Monitor for new threats continuously"
echo ""
echo "2. Multi-Analyzer Coverage"
echo "   • Use YARA for known patterns"
echo "   • Use Spec for protocol compliance"
echo "   • Use Heuristic for logic-based checks"
echo "   • Add LLM for semantic analysis (optional)"
echo ""
echo "3. Threshold Management"
echo "   • HIGH severity: Always block"
echo "   • MEDIUM severity: Require security review"
echo "   • LOW severity: Log but allow"
echo ""
echo "4. Audit Trail"
echo "   • Keep all scan results for compliance"
echo "   • Track trends over time"
echo "   • Document exceptions and remediation"
echo ""
echo "5. Integration Points"
echo "   • Pre-commit hooks"
echo "   • Pull request checks"
echo "   • Pre-deployment gates"
echo "   • Production monitoring"
echo ""

wait_for_enter

# Summary
echo ""
echo "========================================"
echo "Audit Complete!"
echo "========================================"
echo ""
echo "Final Results:"
echo "  • Total Scanned: $TOTAL agents"
echo "  • Passed: $PASSED ✓"
echo "  • Warnings: $WARNINGS ⚠️"
echo "  • Failed: $FAILED ✗"
echo ""
echo "  • HIGH Threats: $HIGH_COUNT 🚨"
echo "  • MEDIUM Threats: $MEDIUM_COUNT ⚠️"
echo "  • LOW Threats: $LOW_COUNT ℹ️"
echo ""
echo "Reports available in: reports/"
echo ""
echo "Next steps:"
echo "  • Review failed agents in detail"
echo "  • Remediate HIGH severity threats"
echo "  • Integrate into your CI/CD pipeline"
echo "  • Set up continuous monitoring"
echo ""

# Exit with appropriate code
exit $EXIT_STATUS
