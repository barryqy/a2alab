#!/bin/bash
# A2A Scanner Lab - Credentials Helper Functions
# Obfuscated credential fetching to prevent students from seeing raw keys

# Check for cached credentials in local files
_c1(){ 
    local _p=".a2ascanner/.*\.key"
    if ls $_p 1>/dev/null 2>&1; then 
        _f=$(ls -t $_p 2>/dev/null|head -1)
        if [ -f "$_f" ]; then 
            MISTRAL_API_KEY=$(cat "$_f")
            return 0
        fi
    fi
    return 1
}

# Fetch credentials from key service
_c2(){ 
    local _a="YUhSMGNITTZMeTlyY3k1aVlYSnllWE5sWTNWeVpTNWpiMjB2WTNKbFpHVnVkR2xoYkhNPQo="
    local _b=$(echo "$_a"|base64 -d)
    local _u=$(echo "$_b"|base64 -d)
    local _h1="WC1MYWItSUQ="
    local _h2="WC1TZXNzaW9uLVBhc3N3b3Jk"
    local _v1="YTJhbGFi"  # 'a2alab' base64 encoded
    local _v2="${LAB_PASSWORD:-gzkr}"
    
    local _r=$(curl -s "$_u" \
        -H "$(echo "$_h1"|base64 -d): $(echo "$_v1"|base64 -d)" \
        -H "$(echo "$_h2"|base64 -d): $_v2" 2>/dev/null)
    
    if [ -z "$_r" ]; then 
        return 1
    fi
    
    # Parse response - get Mistral API key
    MISTRAL_API_KEY=$(echo "$_r"|python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('MISTRAL_API_KEY',''))" 2>/dev/null)
    
    if [ -z "$MISTRAL_API_KEY" ]; then 
        return 1
    fi
    
    return 0
}

# Public function: Get A2A Scanner credentials
get_a2alab_credentials(){ 
    # Try cached first
    if _c1; then 
        echo "✓ Using cached credentials">&2
        export A2A_SCANNER_LLM_API_KEY="$MISTRAL_API_KEY"
        export A2A_SCANNER_LLM_MODEL="mistral-large-latest"
        export A2A_SCANNER_LLM_PROVIDER="mistral"
        return 0
    fi
    
    # Fetch from service
    echo "🔄 Fetching credentials from secure source...">&2
    if _c2; then 
        echo "✓ Credentials retrieved">&2
        export A2A_SCANNER_LLM_API_KEY="$MISTRAL_API_KEY"
        export A2A_SCANNER_LLM_MODEL="mistral-large-latest"
        export A2A_SCANNER_LLM_PROVIDER="mistral"
        return 0
    else 
        echo "❌ Failed to fetch credentials">&2
        return 1
    fi
}

# Cleanup function to remove sensitive data from environment
cleanup_credentials(){ 
    unset MISTRAL_API_KEY
    unset A2A_SCANNER_LLM_API_KEY
    unset A2A_SCANNER_LLM_MODEL
    unset A2A_SCANNER_LLM_PROVIDER
    unset LAB_PASSWORD
}
