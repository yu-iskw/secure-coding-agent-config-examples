#!/bin/bash
# gh-safeguard.sh - Prevent granular data exfiltration using the gh CLI for Cursor

# Initialize debug logging (optional, adjust path as needed)
# echo "Hook execution started" >> /tmp/cursor-hooks.log

# Read JSON input from stdin
input=$(cat)

# For beforeShellExecution, the command is passed directly in the .command field
command=$(echo "${input}" | jq -r '.command // empty')

# Check if the command contains dangerous gh exfiltration or override patterns
if [[ ${command} =~ "gh repo create" ]] || [[ ${command} =~ "gh gist create" ]]; then
	# Block the command
	cat <<EOF
{
  "continue": true,
  "permission": "deny",
  "user_message": "GitHub CLI command blocked to prevent potential data exfiltration.",
  "agent_message": "The command '${command}' has been blocked by a security hook because creating new repositories or gists is strictly forbidden to prevent unauthorized data exfiltration. Please limit usage to querying data."
}
EOF
elif echo "${command}" | grep -qE "gh .*( -R | --repo |repos\/[^/]+\/[^/]+)"; then
	# Block repository overrides to pin gh to the local workspace
	cat <<EOF
{
  "continue": true,
  "permission": "deny",
  "user_message": "GitHub CLI repository override blocked.",
  "agent_message": "The command '${command}' has been blocked because repository overrides using -R, --repo, or explicit API paths are forbidden. This agent is pinned to the local workspace repository for security."
}
EOF
else
	# Allow safe commands
	cat <<EOF
{
  "continue": true,
  "permission": "allow"
}
EOF
fi
