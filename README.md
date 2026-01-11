# A2A Scanner Lab

Hands-on security lab for learning Agent-to-Agent (A2A) protocol security using Cisco A2A Scanner.

## Overview

This lab teaches A2A security through direct hands-on experience with the `a2a-scanner` CLI tool. Students scan real agent cards and see actual threat detection in action.

## Quick Start

### 1. Install A2A Scanner

```bash
# Install UV package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Install A2A Scanner
uv tool install cisco-ai-a2a-scanner

# Verify installation
a2a-scanner --version
a2a-scanner list-analyzers
```

### 2. Clone Lab Repository

```bash
git clone https://github.com/barryqy/a2alab
cd a2alab
```

### 3. Run Initialization Script

```bash
# Automated setup (checks Python, installs dependencies)
bash 0-init-lab.sh
```

### 4. Run Your First Scan

```bash
# Scan a safe agent card
a2a-scanner scan-card examples/safe-agent-card.json --analyzers yara

# Scan a malicious agent card
a2a-scanner scan-card examples/malicious-agent-card.json --analyzers yara
```

## Lab Approach

**Direct CLI Usage** - No wrapper scripts! Students use `a2a-scanner` directly:

1. **Start with example agent cards** (safe or malicious examples provided)
2. **Run a2a-scanner** against them with real CLI commands
3. **See actual threat detection** from YARA patterns, Spec validation, Heuristic analysis
4. **Learn real-world tool usage** that transfers to production

This approach is:
- ✅ **Authentic** - Real security scanning, not simulated
- ✅ **Transparent** - Students see exactly what's happening
- ✅ **Educational** - Learn actual command-line usage
- ✅ **Practical** - Skills apply directly to real-world scenarios

## What's Included

### Example Agent Cards

- **`examples/safe-agent-card.json`** - Properly secured agent (valid structure, HTTPS, reasonable capabilities)
- **`examples/malicious-agent-card.json`** - Intentionally vulnerable (command injection, impersonation, exfiltration)
- **`examples/prompt-injection-agent.json`** - Agent with dangerous prompts and directive injection
- **`examples/data-exfil-agent.json`** - Agent designed to exfiltrate data to external endpoints
- **`examples/mixed-security-agent.json`** - Mix of safe and unsafe capabilities

### Demo Scripts

- **`demo-card-scanning.sh`** - Guided demo of agent card scanning
- **`demo-endpoint-scanning.sh`** - Live endpoint security testing
- **`demo-complete-audit.sh`** - Full security audit workflow

### Utilities

- **`utils/display.py`** - Terminal formatting helpers (colors, tables, progress indicators)

## Lab Exercises

Full lab guide available at: [https://github.com/barryqy/llabsource-a2a](https://github.com/barryqy/llabsource-a2a)

### Exercise 1: Environment Validation
Verify `a2a-scanner` installation and available analyzers

### Exercise 2: Scan Safe Agent Card
Scan a properly secured agent card, learn what "secure" looks like

### Exercise 3: Scan Malicious Agent Card
Detect agent impersonation, prompt injection, data exfiltration, and capability abuse

### Exercise 4: Use Multiple Analyzers
Compare YARA, Spec, and Heuristic analyzer findings

### Exercise 5: Scan Live Endpoints (Optional)
Test running A2A agents for security posture

## Key Features

### YARA Analyzer (No API Keys Required!)
- Pattern-based threat detection
- Detects: agent impersonation, prompt injection, data exfiltration, capability abuse
- Works offline, no credentials needed
- Perfect for learning and development

### Spec Analyzer (No API Keys Required!)
- A2A protocol compliance validation
- Required field checking
- URL format validation
- Data type verification

### Heuristic Analyzer (No API Keys Required!)
- Logic-based security checks
- Detects: superlative language, cloud metadata access, credential harvesting
- Suspicious URL pattern recognition

### LLM Analyzer (Optional - Requires API Key)
- Semantic analysis of agent behavior
- Detects: subtle manipulation, intent classification, context poisoning
- Requires: OpenAI, Anthropic, Azure OpenAI, or Ollama

### Endpoint Analyzer (No API Keys Required!)
- Dynamic testing of running agents
- HTTPS enforcement, security headers validation
- Agent card presence checking
- Protocol compliance verification

## Example Commands

### Basic Scanning

```bash
# Scan with YARA (no API key needed)
a2a-scanner scan-card examples/safe-agent-card.json --analyzers yara

# Detailed output with all findings
a2a-scanner scan-card examples/malicious-agent-card.json \
  --analyzers yara --verbose

# Multiple analyzers
a2a-scanner scan-card examples/malicious-agent-card.json \
  --analyzers yara,spec,heuristic
```

### Save Results

```bash
# JSON output for automation
a2a-scanner scan-card examples/malicious-agent-card.json \
  --output results.json
```

### Scan Live Endpoints

```bash
# Scan a running agent (requires --dev for localhost)
a2a-scanner --dev scan-endpoint http://localhost:8000

# Production agent
a2a-scanner scan-endpoint https://agent.example.com/api
```

### Batch Scanning

```bash
# Scan all examples
for file in examples/*.json; do
  a2a-scanner scan-card "$file" --analyzers yara
done
```

### With LLM Analyzer (Optional)

```bash
# Export API key
export A2A_SCANNER_LLM_PROVIDER=openai
export A2A_SCANNER_LLM_API_KEY="your-openai-key"

# Scan with all analyzers including LLM
a2a-scanner scan-card examples/malicious-agent-card.json \
  --analyzers yara,spec,heuristic,llm
```

## Requirements

- **Python 3.11 - 3.13** (Python 3.14+ not yet supported)
- **A2A Scanner** from [cisco-ai-defense/a2a-scanner](https://github.com/cisco-ai-defense/a2a-scanner)
- **No API credentials required** for YARA, Spec, Heuristic, and Endpoint analyzers
- **Optional API key** for LLM analyzer (advanced semantic analysis)

## Detected Threat Categories

- **Agent Impersonation**: Fake agents mimicking trusted ones
- **Prompt Injection**: Malicious prompts in agent descriptions, directive injection
- **Capability Abuse**: Dangerous or overly broad permissions (execute any command, read any file)
- **Data Exfiltration**: External network requests, unauthorized data transmission
- **Routing Manipulation**: Man-in-the-middle attacks, workflow poisoning
- **Tool Poisoning**: Malicious tool implementations, backdoored capabilities

## Support

**Questions or Issues?**  
Contact Barry Yuan at bayuan@cisco.com

## License

Apache 2.0

## Learn More

- **A2A Scanner**: https://github.com/cisco-ai-defense/a2a-scanner
- **Lab Modules**: https://github.com/barryqy/llabsource-a2a
- **Cisco AI Defense**: https://www.cisco.com/site/us/en/products/security/ai-defense/
- **A2A Protocol**: https://github.com/a2aproject/A2A
