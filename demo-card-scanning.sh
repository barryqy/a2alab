#!/bin/bash

# A2A Scanner Lab - Agent Card Scanning Demo
# This script demonstrates basic agent card scanning with A2A Scanner

echo ""
echo "========================================"
echo "A2A Scanner - Agent Card Scanning Demo"
echo "========================================"
echo ""
echo "This demo shows how to scan A2A agent cards for security threats."
echo ""

# Function to wait for user input
wait_for_enter() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

# Demo 1: Scan Safe Agent Card
echo "[Demo 1] Scanning Safe Agent Card"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This agent card follows security best practices:"
echo "  • HTTPS endpoint"
echo "  • Reasonable capabilities"
echo "  • Proper A2A protocol structure"
echo "  • No suspicious patterns"
echo ""
echo "Command: a2a-scanner scan-card examples/safe-agent-card.json --analyzers yara"
echo ""

a2a-scanner scan-card examples/safe-agent-card.json --analyzers yara

echo ""
echo "✓ Result: No threats detected! This is what a secure agent card looks like."
echo ""

wait_for_enter

# Demo 2: Scan Malicious Agent Card
echo "[Demo 2] Scanning Malicious Agent Card"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This agent card contains multiple security threats:"
echo "  • Agent impersonation attempt"
echo "  • Prompt injection patterns"
echo "  • Data exfiltration URLs"
echo "  • Dangerous capability declarations"
echo "  • Insecure HTTP endpoints"
echo ""
echo "Command: a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara"
echo ""

a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara

echo ""
echo "⚠️  Result: Multiple high-severity threats detected!"
echo ""
echo "Key findings:"
echo "  • Agent impersonation (uses \"Official GPT-4\" without authorization)"
echo "  • Prompt injection (\"Ignore all previous instructions\")"
echo "  • Data exfiltration (suspicious webhook URLs)"
echo "  • Capability abuse (\"execute any command\")"
echo "  • Insecure endpoints (HTTP instead of HTTPS)"
echo ""

wait_for_enter

# Demo 3: Using Multiple Analyzers
echo "[Demo 3] Comparing Different Analyzers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "A2A Scanner includes multiple analyzers for comprehensive threat detection:"
echo "  • YARA: Pattern-based detection (fast)"
echo "  • Spec: A2A protocol compliance"
echo "  • Heuristic: Logic-based security checks"
echo ""
echo "Let's scan the malicious agent with all offline analyzers:"
echo ""
echo "Command: a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara,spec,heuristic"
echo ""

a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara,spec,heuristic

echo ""
echo "Notice how different analyzers detect different types of threats:"
echo "  • YARA: Malicious patterns, known attack signatures"
echo "  • Spec: Protocol violations, missing required fields"
echo "  • Heuristic: Suspicious language, social engineering"
echo ""

wait_for_enter

# Demo 4: Scanning Different Threat Types
echo "[Demo 4] Scanning Specific Threat Types"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Let's scan agent cards with specific threat patterns:"
echo ""

# Prompt Injection
echo "► Prompt Injection Attack:"
echo "  Command: a2a-scanner scan-card examples/prompt-injection-agent.json --analyzers yara"
echo ""
a2a-scanner scan-card examples/prompt-injection-agent.json --analyzers yara
echo ""

wait_for_enter

# Data Exfiltration
echo "► Data Exfiltration Attack:"
echo "  Command: a2a-scanner scan-card examples/data-exfil-agent.json --analyzers yara"
echo ""
a2a-scanner scan-card examples/data-exfil-agent.json --analyzers yara
echo ""

wait_for_enter

# Mixed Security
echo "► Mixed Security Agent (some safe, some suspicious):"
echo "  Command: a2a-scanner scan-card examples/mixed-security-agent.json --analyzers yara"
echo ""
a2a-scanner scan-card examples/mixed-security-agent.json --analyzers yara
echo ""

wait_for_enter

# Demo 5: JSON Output for Automation
echo "[Demo 5] JSON Output for Automation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For CI/CD integration, A2A Scanner can output results in JSON format:"
echo ""
echo "Command: a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara --output /tmp/scan-results.json"
echo ""

a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara --output /tmp/scan-results.json

echo ""
echo "✓ Results saved to /tmp/scan-results.json"
echo ""
echo "Preview of JSON output:"
cat /tmp/scan-results.json | head -n 20
echo "..."
echo ""

# Summary
echo ""
echo "========================================"
echo "Demo Complete!"
echo "========================================"
echo ""
echo "You've learned how to:"
echo "  ✓ Scan agent cards for security threats"
echo "  ✓ Use different analyzers (YARA, Spec, Heuristic)"
echo "  ✓ Identify various threat types"
echo "  ✓ Generate JSON output for automation"
echo ""
echo "Next steps:"
echo "  • Try scanning your own agent cards"
echo "  • Experiment with different analyzer combinations"
echo "  • Run: bash demo-endpoint-scanning.sh for live endpoint testing"
echo ""
