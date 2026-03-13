# A2A Scanner Lab

Hands-on security lab for learning Agent-to-Agent (A2A) protocol security with Cisco A2A Scanner.

## Quick Start

### 1. Install the scanner

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv tool install --python 3.13 cisco-ai-a2a-scanner
a2a-scanner list-analyzers
```

### 2. Clone the lab repo

```bash
cd /home/developer/src
git clone https://github.com/barryqy/a2alab
cd a2alab
```

### 3. Run your first scans

```bash
a2a-scanner scan-card examples/safe-agent-card.json
a2a-scanner scan-card examples/malicious-agent-card.json
```

### 4. Enable the LLM exercises

```bash
source ./lab-env.sh
```

Run that helper before Module 4 or any time you open a fresh shell.

## What's Included

### Example agent cards

- `examples/safe-agent-card.json` - clean baseline with no findings
- `examples/malicious-agent-card.json` - broad attack surface with multiple findings
- `examples/prompt-injection-agent.json` - prompt and instruction manipulation
- `examples/data-exfil-agent.json` - suspicious outbound data handling
- `examples/mixed-security-agent.json` - mixed posture for review practice

### Demo scripts

- `demo-card-scanning.sh` - guided walkthrough of the card examples
- `demo-endpoint-scanning.sh` - live endpoint scans against local test servers
- `demo-complete-audit.sh` - batch audit with saved JSON reports

## Key Commands

### Default card scans

```bash
a2a-scanner scan-card examples/safe-agent-card.json
a2a-scanner scan-card examples/malicious-agent-card.json
```

### Save JSON output

```bash
a2a-scanner scan-card examples/malicious-agent-card.json \
  --output results.json
```

### Live endpoint scans

```bash
a2a-scanner --dev scan-endpoint http://localhost:8000
a2a-scanner --dev scan-endpoint http://localhost:8001
```

### Optional LLM sanity check

```bash
source ./lab-env.sh
a2a-scanner scan-card examples/malicious-agent-card.json \
  --analyzers llm
```

## Notes

- The default scan already uses the shipped offline analyzers.
- The LLM analyzer is optional and is introduced in Module 4.
- `demo-complete-audit.sh --json` is useful for automation and CI checks.
- The audit demo exits non-zero when the intentionally unsafe sample cards are found.

## Full Lab Guide

[https://github.com/barryqy/llabsource-a2a](https://github.com/barryqy/llabsource-a2a)

## Requirements

- `uv`
- Python 3.13 for the scanner tool
- No API credentials required for the offline analyzers

## Learn More

- [A2A Scanner](https://github.com/cisco-ai-defense/a2a-scanner)
- [Cisco AI Defense](https://www.cisco.com/site/us/en/products/security/ai-defense/)
- [A2A Protocol](https://github.com/a2aproject/A2A)
