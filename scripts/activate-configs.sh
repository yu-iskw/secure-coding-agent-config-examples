#!/bin/bash

# activate-configs.sh: Smartly symlinks agent configurations from the repository
# to their respective local hidden directories.

set -e

DRY_RUN=false
AGENT_FILTER=""

while [[ $# -gt 0 ]]; do
	case $1 in
	--dry-run) DRY_RUN=true ;;
	--claude) AGENT_FILTER="claude" ;;
	--cursor) AGENT_FILTER="cursor" ;;
	--codex) AGENT_FILTER="codex" ;;
	--gemini) AGENT_FILTER="gemini" ;;
	--copilot) AGENT_FILTER="copilot" ;;
	--antigravity) AGENT_FILTER="antigravity" ;;
	*)
		echo "Unknown parameter: $1"
		exit 1
		;;
	esac
	shift
done

if [[ ${DRY_RUN} == "true" ]]; then
	echo "Dry run mode: No changes will be made."
fi

# Function to safely create a symlink
# Usage: safe_link <src_relative_to_repo_root> <dest_relative_to_repo_root>
safe_link() {
	local src="$1"
	local dest="$2"

	if [[ ! -e ${src} ]]; then
		return
	fi

	# Ensure destination parent directory exists
	local dest_dir
	dest_dir=$(dirname "${dest}")
	if [[ ! -d ${dest_dir} ]]; then
		if [[ ${DRY_RUN} == "true" ]]; then
			echo "[Dry Run] Would create directory ${dest_dir}"
		else
			mkdir -p "${dest_dir}"
		fi
	fi

	if [[ ${DRY_RUN} == "true" ]]; then
		echo "[Dry Run] Would symlink ${src} -> ${dest}"
	else
		# Remove existing file or link at destination
		if [[ -e ${dest} || -L ${dest} ]]; then
			rm "${dest}"
		fi
		local current_pwd
		current_pwd=$(pwd)
		ln -s "${current_pwd}/${src}" "${dest}"
		echo "Symlinked ${src} -> ${dest}"
	fi
}

# Function to link all files in a directory (recursive)
# Usage: link_dir_contents <src_dir> <dest_dir>
link_dir_contents() {
	local src_dir="$1"
	local dest_dir="$2"

	if [[ ! -d ${src_dir} ]]; then
		return
	fi

	# shellcheck disable=SC2312
	find "${src_dir}" -maxdepth 1 -type f | while read -r file; do
		local filename
		filename=$(basename "${file}")
		safe_link "${file}" "${dest_dir}/${filename}"
	done
}

# Agent Configurations

# Claude Code
if [[ -z ${AGENT_FILTER} || ${AGENT_FILTER} == "claude" ]]; then
	safe_link "claude-code/settings.json" ".claude/settings.json"
	link_dir_contents "claude-code/hooks" ".claude/hooks"
fi

# Cursor
if [[ -z ${AGENT_FILTER} || ${AGENT_FILTER} == "cursor" ]]; then
	safe_link "cursor/sandbox.json" ".cursor/sandbox.json"
	safe_link "cursor/hooks.json" ".cursor/hooks.json"
	link_dir_contents "cursor/rules" ".cursor/rules"
	link_dir_contents "cursor/hooks" ".cursor/hooks"
fi

# Codex
if [[ -z ${AGENT_FILTER} || ${AGENT_FILTER} == "codex" ]]; then
	safe_link "codex/config.toml" ".codex/config.toml"
	link_dir_contents "codex/hooks" ".codex/hooks"
fi

# Gemini CLI
if [[ -z ${AGENT_FILTER} || ${AGENT_FILTER} == "gemini" ]]; then
	safe_link "gemini-cli/settings.json" ".gemini/settings.json"
	link_dir_contents "gemini-cli/hooks" ".gemini/hooks"
fi

# Copilot CLI
if [[ -z ${AGENT_FILTER} || ${AGENT_FILTER} == "copilot" ]]; then
	safe_link "copilot-cli/config.json" ".copilot/config.json"
fi

# Antigravity
if [[ -z ${AGENT_FILTER} || ${AGENT_FILTER} == "antigravity" ]]; then
	safe_link "antigravity/config.json" ".antigravity/config.json"
	link_dir_contents "antigravity/hooks" ".antigravity/hooks"
fi

echo "Activation complete!"
