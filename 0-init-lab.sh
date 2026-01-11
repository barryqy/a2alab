#!/bin/bash

# A2A Scanner Lab - Initialization Script
# This script sets up the lab environment and installs A2A Scanner

set -e

echo ""
echo "========================================"
echo "A2A Scanner Lab - Environment Setup"
echo "========================================"
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
        echo "❌ Installation failed. Please check the error messages above."
        exit 1
    fi
else
    if uv tool install cisco-ai-a2a-scanner; then
        echo ""
        echo "[✓] A2A Scanner installed successfully!"
    else
        echo ""
        echo "❌ Installation failed. Please check the error messages above."
        exit 1
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
    echo "❌ Verification failed. a2a-scanner command not found."
    echo "    Try adding to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi

echo ""
echo "========================================"
echo "Setup Complete! 🎉"
echo "========================================"
echo ""
echo "You're ready to start scanning!"
echo ""
echo "Next steps:"
echo "  1. Review example agent cards in examples/"
echo "  2. Run demo scripts: bash demo-card-scanning.sh"
echo "  3. Try scanning: a2a-scanner scan-card examples/safe-agent-card.json"
echo ""
echo "For command reference: cat reference/QUICK_REFERENCE.md"
echo ""
