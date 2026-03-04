---
name: deploy-configs
description: Deploy and activate agent-specific configurations (settings, hooks, rules) from the repository to the local environment via symlinks.
allowed-tools: Bash
---

# Deploy Agent Configs

## Purpose

Use this skill to "activate" the security-focused configurations provided in this repository for various AI coding agents (Claude Code, Cursor, Codex, Gemini CLI, etc.). It symlinks the repository's configuration files to the appropriate local hidden directories (e.g., `.claude/`, `.cursor/`), allowing you to test and use these configurations immediately without manual copying.

## Instructions

1. **Activate All Configs**:
   To activate configurations for all supported agents at once, run:

   ```bash
   make activate
   ```

2. **Activate Specific Agent Configs**:
   To activate configurations for a specific agent, use the corresponding make target:
   - Claude Code: `make activate-claude`
   - Cursor: `make activate-cursor`
   - Codex: `make activate-codex`
   - Gemini CLI: `make activate-gemini`
   - Copilot CLI: `make activate-copilot`
   - Antigravity: `make activate-antigravity`

3. **Dry Run**:
   To see what changes would be made without actually creating any symlinks, run:

   ```bash
   make activate-dry
   ```

4. **Verification**:
   After activation, the configurations are live. For example, Claude Code will now use the `settings.json` from `claude-code/` via the symlink at `.claude/settings.json`.

## Smart Deployment Details

The activation script is designed to be "skill-safe":

- It symlinks individual files rather than entire directories.
- This ensures that your existing local skills (e.g., in `.claude/skills/`) are preserved and not overwritten.
- It automatically creates any missing local hidden directories as needed.
