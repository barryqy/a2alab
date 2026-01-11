#!/bin/bash

# A2A Scanner Lab - Initialization Script
# This script sets up credentials securely for the A2A Scanner lab

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     A2A Scanner Lab - Credential Setup                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Prompt for lab password (only once!)
echo "════════════════════════════════════════════════════════════"
echo "🔐 🔐 🔐  PASSWORD REQUIRED  🔐 🔐 🔐"
echo "════════════════════════════════════════════════════════════"
echo ""
read -sp "👉 Enter lab password: " LAB_PASSWORD
echo ""
echo ""

if [ -z "$LAB_PASSWORD" ]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

export LAB_PASSWORD

# Source shared credentials helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.credentials-helper.sh"

echo "🔄 Fetching credentials from secure source..."
echo ""

# Fetch credentials using the helper
if ! get_a2alab_credentials; then
    echo "❌ Failed to fetch credentials"
    echo "   Please check your password and internet connection"
    exit 1
fi

echo "✓ Credentials retrieved successfully"
echo ""

# Create .a2ascanner directory if it doesn't exist
mkdir -p .a2ascanner
chmod 700 .a2ascanner

# Write credentials to cache file
echo "📝 Caching session data..."

# Create cache file with mixed content
CACHE_FILE=".a2ascanner/.cache"
TIMESTAMP=$(date +%s)
SESSION_ID=$(openssl rand -hex 16 2>/dev/null || echo $(date +%s%N | md5sum | cut -d' ' -f1))

# Prepare session data
ENCRYPTION_KEY="${DEVENV_USER:-default-key-fallback}"

# Build session payload (just Mistral key for now)
PLAINTEXT="${MISTRAL_API_KEY}"

# Encode session data
ENCRYPTED=$(python3 << PYPYTHON
import sys
import base64

plaintext = """${PLAINTEXT}"""
key = """${ENCRYPTION_KEY}"""

# Encode with session key
def xor_encrypt(data, key):
    key_repeated = (key * (len(data) // len(key) + 1))[:len(data)]
    return bytes(a ^ b for a, b in zip(data.encode(), key_repeated.encode()))

encrypted = xor_encrypt(plaintext, key)
print(base64.b64encode(encrypted).decode(), end='')
PYPYTHON
)

# Create minimal cache content
cat > "$CACHE_FILE" << EOF
# Session cache - DO NOT EDIT
session_start=$TIMESTAMP
session_id=$SESSION_ID
cache_version=1.0.0
sdk_version=1.0.0
last_sync=$TIMESTAMP
session_token=$ENCRYPTED
EOF

chmod 600 "$CACHE_FILE"

echo "✓ Session cache created"
echo ""

# Export environment variables for immediate use
echo "🔒 Exporting credentials as environment variables..."
export A2A_SCANNER_LLM_API_KEY
export A2A_SCANNER_LLM_MODEL="mistral-large-latest"
export A2A_SCANNER_LLM_PROVIDER="mistral"

echo "✓ Environment variables configured"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "✅ Lab initialization complete!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "💡 You can now use ALL A2A Scanner analyzers:"
echo "   • YARA Analyzer      - Pattern matching"
echo "   • Spec Analyzer      - A2A compliance"
echo "   • Heuristic Analyzer - Logic-based checks"
echo "   • LLM Analyzer       - AI-powered with Mistral ✓ ENABLED"
echo ""
echo "💡 Example commands:"
echo "   a2a-scanner scan-card examples/safe-agent-card.json"
echo "   a2a-scanner scan-card examples/malicious-agent-card.json"
echo ""
echo "   ./demo-card-scanning.sh       (Basic scanning demo)"
echo "   ./demo-complete-audit.sh      (Full security audit)"
echo ""

# Clean up sensitive variables from memory
cleanup_credentials

echo "📌 Note: Credentials are cached. To refresh, re-run this script."
echo ""
