---
name: update-agent-configs
description: Research and update secure configuration files for Cursor, Claude Code, Codex, Gemini CLI, Antigravity, and GitHub Copilot CLI. Use when asked to update agent settings or refresh sandbox security practices.
license: Apache-2.0
allowed-tools: WebSearch WebFetch
---

# Update Agent Configs

## Purpose

Periodically research the latest security best practices, documentation, and vulnerability reports for AI coding agents (Cursor, Claude Code, Codex, Gemini CLI, Antigravity, GitHub Copilot CLI) and update their respective local configuration files (`settings.json`, `config.toml`, `sandbox.json`, etc.) and markdown guides. This ensures that the security baselines provided by this repository remain effective against emerging supply-chain attacks.

## Instructions

1. **Read References**: Read the file `references/documentation-urls.md` to get the list of official documentation links for each AI coding agent.
2. **Fetch Latest Docs**: For each tool, use `WebSearch` or `WebFetch` to gather the latest sandbox and security settings from the official URLs.
3. **Search for Vulnerabilities**: Use `WebSearch` to search for recent security vulnerabilities related to these agents (e.g., search terms like `"AI agent sandbox escape [Current Year]"` or `"[Agent Name] security vulnerability"`).
4. **Compare Configurations**: Compare the newly gathered information with the current local configuration files (e.g., `cursor/sandbox.json`, `claude-code/settings.json`, `codex/config.toml`, etc.). Look for:
    * New settings or flags that should be enabled.
    * Deprecated settings that should be removed.
    * New default bypasses or exploits that need explicitly mitigating.
5. **Apply Updates**:
    * Modify the configuration files to implement the latest secure-by-default practices.
    * Update the inline comments in the configuration files to explain the changes.
    * Update the respective `README.md` files in each agent's directory to reflect the new instructions or threat landscape.

## Examples

### Example 1: Updating Cursor Settings

**Input**: "Please update the agent configs."
**Execution**:

* Agent reads `references/documentation-urls.md`.
* Agent fetches `https://cursor.com/docs/agent/terminal`.
* Agent discovers a new property `restrictSubprocesses` added to `sandbox.json` in a recent update.
* Agent updates `cursor/sandbox.json` to include `"restrictSubprocesses": true`.
* Agent updates `cursor/README.md` to document the new property and how it mitigates attacks.

## Additional Resources

* [Documentation URLs](references/documentation-urls.md)
