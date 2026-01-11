# A2A Scanner - Quick Reference Guide

This guide provides quick reference for common A2A Scanner commands and usage patterns.

## Installation

```bash
# Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Install A2A Scanner
uv tool install cisco-ai-a2a-scanner

# Verify installation
a2a-scanner --version
a2a-scanner list-analyzers
```

## Basic Commands

### Scan Agent Card

```bash
# Basic scan with YARA analyzer
a2a-scanner scan-card agent.json --analyzers yara

# Multiple analyzers
a2a-scanner scan-card agent.json --analyzers yara,spec,heuristic

# With JSON output
a2a-scanner scan-card agent.json --analyzers yara --output results.json

# Verbose mode
a2a-scanner scan-card agent.json --analyzers yara --verbose
```

### Scan Live Endpoint

```bash
# Production endpoint
a2a-scanner scan-endpoint https://agent.example.com/api

# Localhost (requires --dev flag)
a2a-scanner --dev scan-endpoint http://localhost:8000

# With authentication
a2a-scanner scan-endpoint https://agent.example.com/api \
  --bearer-token "$TOKEN"
```

### Scan Directory

```bash
# Scan all JSON files in directory
a2a-scanner scan-directory ./agents

# With pattern matching
a2a-scanner scan-directory ./agents --pattern "*.json"
```

### Scan Registry

```bash
# Scan agents from registry
a2a-scanner scan-registry https://registry.example.com/.well-known/agents
```

## Analyzer Selection

### YARA Analyzer (No API Key Required)
Pattern-based threat detection. Fast, offline, high accuracy.

```bash
a2a-scanner scan-card agent.json --analyzers yara
```

**Detects:**
- Agent impersonation
- Prompt injection
- Data exfiltration
- Capability abuse
- Command injection

### Spec Analyzer (No API Key Required)
A2A protocol compliance validation.

```bash
a2a-scanner scan-card agent.json --analyzers spec
```

**Validates:**
- Required fields
- URL formats
- Data types
- Protocol structure

### Heuristic Analyzer (No API Key Required)
Logic-based security checks.

```bash
a2a-scanner scan-card agent.json --analyzers heuristic
```

**Detects:**
- Superlative language (social engineering)
- Cloud metadata access patterns
- Suspicious URL patterns
- Credential harvesting indicators

### LLM Analyzer (Requires API Key)
AI-powered semantic analysis.

```bash
# Configure LLM provider
export A2A_SCANNER_LLM_PROVIDER=openai
export A2A_SCANNER_LLM_API_KEY=sk-...
export A2A_SCANNER_LLM_MODEL=gpt-4o

# Scan with LLM
a2a-scanner scan-card agent.json --analyzers llm
```

**Detects:**
- Subtle manipulation
- Intent classification
- Context poisoning
- Semantic threats

### Endpoint Analyzer (No API Key Required)
Live endpoint security testing.

```bash
a2a-scanner scan-endpoint https://agent.example.com/api
```

**Tests:**
- HTTPS enforcement
- Security headers
- Agent card presence
- URL consistency
- Health endpoints

## Output Formats

### Summary (Default)
Human-readable, color-coded output

```bash
a2a-scanner scan-card agent.json
```

### JSON
Machine-readable for automation

```bash
a2a-scanner scan-card agent.json --output results.json
```

### Verbose
Detailed information including matched patterns

```bash
a2a-scanner scan-card agent.json --verbose
```

## Common Workflows

### Pre-Commit Check

```bash
#!/bin/bash
# pre-commit-scan.sh

for file in $(git diff --cached --name-only | grep '\.json$'); do
  a2a-scanner scan-card "$file" --analyzers yara,spec
  if [ $? -ne 0 ]; then
    echo "Security issues detected in $file"
    exit 1
  fi
done
```

### Batch Scanning

```bash
# Scan all agent cards
for card in agents/*.json; do
  echo "Scanning: $card"
  a2a-scanner scan-card "$card" --analyzers yara
done
```

### CI/CD Integration

```yaml
# .github/workflows/security.yml
name: A2A Security Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install A2A Scanner
        run: |
          curl -LsSf https://astral.sh/uv/install.sh | sh
          uv tool install cisco-ai-a2a-scanner
      
      - name: Scan Agent Cards
        run: a2a-scanner scan-directory agents/ --analyzers yara,spec
```

### Continuous Monitoring

```bash
#!/bin/bash
# monitor-endpoints.sh (run via cron)

ENDPOINTS=(
  "https://agent1.example.com/api"
  "https://agent2.example.com/api"
)

DATE=$(date +%Y-%m-%d)
REPORT_DIR="reports/$DATE"
mkdir -p "$REPORT_DIR"

for endpoint in "${ENDPOINTS[@]}"; do
  name=$(basename "$endpoint")
  a2a-scanner scan-endpoint "$endpoint" \
    --output "$REPORT_DIR/$name.json"
done
```

## Development Mode

For local testing, use `--dev` flag:

```bash
# Allows localhost, private IPs, HTTP, self-signed certs
a2a-scanner --dev scan-endpoint http://localhost:8000
```

**⚠️ WARNING**: Never use `--dev` in production!

## Environment Variables

### LLM Configuration

```bash
# OpenAI
export A2A_SCANNER_LLM_PROVIDER=openai
export A2A_SCANNER_LLM_API_KEY=sk-...
export A2A_SCANNER_LLM_MODEL=gpt-4o

# Anthropic Claude
export A2A_SCANNER_LLM_PROVIDER=anthropic
export A2A_SCANNER_LLM_API_KEY=sk-ant-...
export A2A_SCANNER_LLM_MODEL=claude-3-5-sonnet-20241022

# Azure OpenAI
export A2A_SCANNER_LLM_PROVIDER=azure
export A2A_SCANNER_LLM_API_KEY=your-key
export A2A_SCANNER_LLM_BASE_URL=https://your-resource.openai.azure.com
export A2A_SCANNER_LLM_API_VERSION=2024-02-15-preview
export A2A_SCANNER_LLM_MODEL=gpt-4

# Local Ollama
export A2A_SCANNER_LLM_PROVIDER=ollama
export A2A_SCANNER_LLM_BASE_URL=http://localhost:11434
export A2A_SCANNER_LLM_MODEL=llama3
```

## Threat Categories

| Category | Description | Analyzer |
|----------|-------------|----------|
| **Agent Impersonation** | Fake agents mimicking trusted ones | YARA, LLM |
| **Prompt Injection** | Malicious prompts in descriptions | YARA, LLM |
| **Capability Abuse** | Dangerous or overly broad permissions | YARA, Heuristic |
| **Data Exfiltration** | Unauthorized data transmission | YARA, Heuristic |
| **Routing Manipulation** | Intercepting agent communications | LLM |
| **Tool Poisoning** | Malicious tool implementations | YARA, LLM |
| **Protocol Violation** | A2A spec non-compliance | Spec |
| **Insecure Endpoints** | HTTP instead of HTTPS | Spec, Endpoint |

## Severity Levels

- **HIGH** 🚨: Critical threats, block deployment
- **MEDIUM** ⚠️: Significant concerns, require review
- **LOW** ℹ️: Minor issues, log and monitor

## Exit Codes

- `0`: No threats detected (clean scan)
- `1`: Threats detected or scan failed
- `2`: Invalid arguments or configuration error

## Troubleshooting

### Command Not Found

```bash
# Add uv bin directory to PATH
export PATH="$HOME/.local/bin:$PATH"

# Reinstall if needed
uv tool install cisco-ai-a2a-scanner
```

### YARA Rules Not Found

```bash
# Reinstall A2A Scanner
uv tool uninstall cisco-ai-a2a-scanner
uv tool install cisco-ai-a2a-scanner
```

### LLM Analyzer Unavailable

```bash
# Check API key is set
echo $A2A_SCANNER_LLM_API_KEY

# Configure provider
export A2A_SCANNER_LLM_PROVIDER=openai
export A2A_SCANNER_LLM_API_KEY=your-key
```

## Best Practices

1. **Use Multiple Analyzers**: Combine YARA, Spec, and Heuristic for comprehensive coverage
2. **Automate Scanning**: Integrate into CI/CD pipelines
3. **Regular Updates**: Keep A2A Scanner updated with `uv tool upgrade`
4. **Monitor Production**: Scan endpoints regularly, not just agent cards
5. **Document Exceptions**: Track false positives and security reviews
6. **Set Thresholds**: Define what severity levels block deployment
7. **Audit Logging**: Keep scan results for compliance

## Quick Examples

```bash
# Complete scan with all offline analyzers
a2a-scanner scan-card agent.json --analyzers yara,spec,heuristic

# Scan and save for review
a2a-scanner scan-card agent.json --analyzers yara --output scan.json

# Check if any HIGH severity threats
a2a-scanner scan-card agent.json --analyzers yara
if [ $? -ne 0 ]; then
  echo "Threats detected!"
fi

# Scan all examples
for card in examples/*.json; do
  a2a-scanner scan-card "$card" --analyzers yara
done

# Production endpoint check
a2a-scanner scan-endpoint https://agent.example.com/api
```

## Additional Resources

- **A2A Scanner GitHub**: https://github.com/cisco-ai-defense/a2a-scanner
- **Lab Guide**: https://github.com/barryqy/llabsource-a2a
- **A2A Protocol**: https://github.com/a2aproject/A2A
- **Cisco AI Defense**: https://www.cisco.com/site/us/en/products/security/ai-defense/

## Support

- **Questions**: bayuan@cisco.com
- **Issues**: https://github.com/cisco-ai-defense/a2a-scanner/issues
- **Documentation**: https://github.com/cisco-ai-defense/a2a-scanner/tree/main/docs
