# Codex Security Guide

Codex provides robust security controls through an OS-enforced sandbox and a customizable approval policy. This guide helps you configure Codex to protect against unauthorized execution attacks, such as the one discovered by Socket.dev involving the Aqua Trivy VS Code extension.

## The Threat

Malicious extensions or scripts can attempt to hijack locally installed AI agents by invoking them with highly permissive flags. For Codex, attackers might use:
`codex exec "prompt" --ask-for-approval never --sandbox danger-full-access`

This command attempts to bypass all safeguards, giving the agent full access to your filesystem and network without prompting you for permission.

## The Solution

By explicitly configuring your `~/.codex/config.toml`, you establish secure baseline defaults.

### Recommended Configuration (`config.toml`)

Copy the provided [`config.toml`](config.toml) to your `~/.codex/` directory.

Key security settings include:

- **`sandbox_mode = "workspace-write"`**: Restricts the agent to reading and editing files only within your current active workspace. It cannot modify system files or access sensitive directories outside the project.
- **`approval_policy = "untrusted"`**: Ensures that Codex will ask for your approval before executing any commands that require network access, modify state, or are otherwise deemed "untrusted". This prevents the agent from silently exfiltrating data or running destructive commands.
- **`allow_login_shell = false`**: Disables login shells for shell-based tools, reducing the attack surface.
- **`[sandbox_workspace_write] network_access = false`**: Explicitly disables network access in the default workspace-write mode.
- **`web_search = "cached"`**: Uses OpenAI's cached index for web searches instead of live browsing, mitigating risks of prompt injection from live websites.

## Managing Approvals and Shell Executions

Even with these settings, you maintain control. Because the `approval_policy` is set to `"untrusted"`, Codex will natively intercept all shell commands (like `gh repo create` or `curl`) and pause to ask for your explicit manual approval. This serves as a granular security check against data exfiltration. If Codex needs to perform an action outside these boundaries (e.g., install a package from the network), it will pause and prompt you for approval.

**Never** use the `--dangerously-bypass-approvals-and-sandbox` or `--yolo` flags unless you are in a completely isolated, disposable environment (like a dedicated, untrusted Docker container).

## References

- [Official Codex Security Documentation](https://developers.openai.com/codex/security/)
- [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
