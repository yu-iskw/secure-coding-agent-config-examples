#!/bin/bash
# gh-safeguard.sh - Prevent granular data exfiltration using the gh CLI

# Read the JSON hook payload from stdin
INPUT=$(cat)

# Extract the command to be executed (handles Gemini CLI and general schemas)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // .args.command // empty')

# Check for dangerous exfiltration patterns
if echo "$COMMAND" | grep -qE "(gh\s+repo\s+create|gh\s+gist\s+create)"; then
  echo "Security Block: Execution of 'gh repo create' or 'gh gist create' is STRICTLY FORBIDDEN to prevent unauthorized data exfiltration to public endpoints." >&2
  exit 2
fi

# Allow execution
exit 0
