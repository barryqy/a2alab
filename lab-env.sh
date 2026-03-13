#!/bin/bash
# Load the lab's built-in LLM settings for the A2A Scanner exercises.

export PATH="$HOME/.local/bin:$PATH"

if [ -n "${LLM_API_KEY:-}" ]; then
  export A2A_SCANNER_LLM_API_KEY="${LLM_API_KEY}"
fi

if [ -n "${LLM_BASE_URL:-}" ]; then
  export A2A_SCANNER_LLM_BASE_URL="${LLM_BASE_URL}"
fi

export A2A_SCANNER_LLM_PROVIDER="${A2A_SCANNER_LLM_PROVIDER:-openai}"
export A2A_SCANNER_LLM_MODEL="${A2A_SCANNER_LLM_MODEL:-gpt-4o}"

if [ -n "${A2A_SCANNER_LLM_API_KEY:-}" ] && [ -n "${A2A_SCANNER_LLM_BASE_URL:-}" ]; then
  echo "✅ Lab LLM settings loaded"
  echo "   Provider: ${A2A_SCANNER_LLM_PROVIDER}"
  echo "   Model: ${A2A_SCANNER_LLM_MODEL}"
  echo ""
  echo "💡 You can now run: a2a-scanner list-analyzers"
  return 0 2>/dev/null || exit 0
fi

echo "⚠️  Lab LLM settings are not available in this shell."
echo "   You can still use the offline analyzers right away."
return 1 2>/dev/null || exit 1
