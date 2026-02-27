#!/bin/bash

# A2A Scanner Lab - Initialization Script
# This script sets up the A2A Scanner environment and credentials

IS_SOURCED=false
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    IS_SOURCED=true
fi

WAS_ERREXIT=0
case "$-" in
    *e*) WAS_ERREXIT=1 ;;
esac

die() {
    local msg="$1"
    echo "$msg"
    if [ "$IS_SOURCED" = true ]; then
        return 1
    fi
    exit 1
}

main() {
    set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     A2A Scanner Lab - Environment Setup                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Script directory (used for local credential file lookup, too)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# TEMPORARY (LOCAL ONLY): Non-interactive password shortcut
# --------------------------------------------------------------------
# This mirrors the pattern used in the `../aidefense` lab for live events.
# To use it, uncomment and paste the event password below *in your local copy*.
# Do NOT commit the password to source control.
#
# LAB_PASSWORD="PASTE_EVENT_PASSWORD_HERE"
#
# Preferred alternative (also non-interactive, gitignored):
#   .reference/credentials/lab-password
# --------------------------------------------------------------------

# NOTE:
# This script is typically *executed* (e.g., `bash 0-init-lab.sh`), not sourced.
# Environment changes like PATH updates do not persist back to the parent shell.
# We therefore ensure PATH inside this script, and print the one-liner you
# should run in your terminal afterwards.

# Lab password (supports non-interactive usage)
# Priority:
#  1) LAB_PASSWORD (if already set)
#  2) A2ALAB_LAB_PASSWORD (if set)
#  3) .reference/credentials/lab-password (if present)
#  4) Prompt user
if [ -z "${LAB_PASSWORD:-}" ] && [ -n "${A2ALAB_LAB_PASSWORD:-}" ]; then
    LAB_PASSWORD="$A2ALAB_LAB_PASSWORD"
fi

if [ -z "${LAB_PASSWORD:-}" ]; then
    for pwfile in \
        "$SCRIPT_DIR/.reference/credentials/lab-password" \
        "$PWD/.reference/credentials/lab-password"
    do
        if [ -f "$pwfile" ]; then
            LAB_PASSWORD="$(tr -d '\r\n' < "$pwfile")"
            break
        fi
    done
fi

if [ -z "${LAB_PASSWORD:-}" ]; then
    echo "════════════════════════════════════════════════════════════"
    echo "🔐 🔐 🔐  PASSWORD REQUIRED  🔐 🔐 🔐"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    read -sp "👉 Enter lab password: " LAB_PASSWORD
    echo ""
    echo ""
fi

if [ -z "${LAB_PASSWORD:-}" ]; then
    die "❌ Password cannot be empty"
fi

export LAB_PASSWORD

echo "✓ Password set. Starting installation..."
echo ""

# Check Python version
echo "[✓] Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 11 ] && [ "$PYTHON_MINOR" -le 13 ]; then
    echo "    Python $PYTHON_VERSION detected - Compatible!"
    USE_UV_PYTHON=false
else
    echo "    ⚠️  Python $PYTHON_VERSION detected"
    echo "    A2A Scanner requires Python 3.11, 3.12, or 3.13"
    echo ""
    echo "    No worries! We'll use 'uv' to manage Python 3.13 for this lab."
    echo "    (This won't affect your system Python)"
    USE_UV_PYTHON=true
fi

echo ""

# Check for uv
echo "[✓] Checking for uv package manager..."
if command -v uv &> /dev/null; then
    UV_VERSION=$(uv --version | awk '{print $2}')
    echo "    uv is already installed: uv $UV_VERSION"
else
    echo "    uv not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo "    uv installed successfully!"
fi

echo ""

# Install A2A Scanner
echo "[ ] Installing A2A Scanner CLI tool..."
if [ "$USE_UV_PYTHON" = true ]; then
    echo "    Running: uv tool install --python 3.13 cisco-ai-a2a-scanner"
    echo "    (uv will automatically download Python 3.13 if needed)"
else
    echo "    Running: uv tool install cisco-ai-a2a-scanner"
fi
echo ""

# Ensure PATH includes uv bin directory
export PATH="$HOME/.local/bin:$PATH"

# Install A2A Scanner with appropriate Python version
if [ "$USE_UV_PYTHON" = true ]; then
    if uv tool install --python 3.13 cisco-ai-a2a-scanner; then
        echo ""
        echo "[✓] A2A Scanner installed successfully with Python 3.13!"
        echo "    (Managed by uv, isolated from your system Python)"
    else
        echo ""
        die "❌ Installation failed. Please check the error messages above."
    fi
else
    if uv tool install cisco-ai-a2a-scanner; then
        echo ""
        echo "[✓] A2A Scanner installed successfully!"
    else
        echo ""
        die "❌ Installation failed. Please check the error messages above."
    fi
fi

echo ""

# Verify installation
echo "[ ] Verifying installation..."
echo "    Running: a2a-scanner list-analyzers"
echo ""

if a2a-scanner list-analyzers; then
    echo ""
    echo "[✓] Installation verification complete!"
else
    echo ""
    die "❌ Verification failed. a2a-scanner command not found.
    Try adding to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""

# Source shared credentials helper
source "${SCRIPT_DIR}/.credentials-helper.sh"

echo "🔄 Fetching credentials from secure source..."
echo ""

# Fetch credentials using the helper
if ! get_a2alab_credentials; then
    die "❌ Failed to fetch credentials
   Please check your password and internet connection"
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
export A2A_SCANNER_LLM_MODEL="mistral/mistral-large-latest"
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

if [ "$IS_SOURCED" = true ]; then
    echo "💡 This script was sourced, so PATH updates persist in this terminal."
    echo "   You can now run: a2a-scanner scan-card examples/safe-agent-card.json --analyzers yara"
    echo ""
else
    echo "💡 In this terminal, run the following so `a2a-scanner` is found:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi
}

main_status=0
if [ "$IS_SOURCED" = true ]; then
    main || main_status=$?
    if [ "$WAS_ERREXIT" -eq 0 ]; then
        set +e
    fi
    return "$main_status"
else
    main
    exit $?
fi
