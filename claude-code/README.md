# Claude Code Security Guide

Claude Code features native sandboxing that uses OS-level primitives (Seatbelt on macOS, bubblewrap on Linux/WSL2) to enforce filesystem and network isolation. This guide explains how to configure these protections to prevent unauthorized execution by malicious scripts or extensions.

## The Threat

Attackers can use malicious VS Code extensions or scripts to silently invoke Claude Code and exfiltrate data. The Socket.dev report identified the following exploit command:
`claude -p --dangerously-skip-permissions --add-dir / "prompt"`

This command attempts to bypass permissions entirely, granting Claude read access to the entire root filesystem (`/`) and instructing it to gather and transmit sensitive information.

## The Solution

By configuring Claude Code's sandboxing, you define strict boundaries that OS-level controls enforce, even if a process attempts to invoke Claude with dangerous flags.

### Recommended Configuration (`settings.json`)

Copy the provided [`settings.json`](settings.json) to your project or global settings directory.

Key security settings include:

- **`"enabled": true`**: Activates the sandboxing runtime. All bash commands and subprocesses will be constrained by the sandbox.
- **`"allowUnsandboxedCommands": false`**: Disables the escape hatch. If a command fails inside the sandbox, Claude Code might normally attempt to retry it with the `dangerouslyDisableSandbox` parameter. Setting this to `false` ensures that all commands must run sandboxed or be explicitly whitelisted.
- **`filesystem.denyWrite` and `denyRead`**: explicitly blocks access to sensitive directories like `~/.ssh` and configuration files (`~/.bashrc`, `~/.zshrc`) to prevent unauthorized credential access or persistence mechanisms.
- **`network.allowedDomains`**: Creates an explicit allowlist for network access. Any connection attempt to a domain not on this list will be blocked by the proxy, severely limiting the attacker's ability to exfiltrate data.

## Granular Security Hooks

While network domain restrictions (e.g., allowing `github.com`) are essential, they do not prevent an attacker from using allowed domains for exfiltration (e.g., using `gh repo create` to push data to an attacker-owned repository).

To address this, we use **PreToolUse Hooks** to intercept commands before they are executed by the shell.

### How to use the `gh-safeguard.sh` hook:

1. Copy the `hooks/gh-safeguard.sh` script to your project's `.claude/hooks/` directory.
2. Make the script executable: `chmod +x .claude/hooks/gh-safeguard.sh`
3. Ensure your `settings.json` includes the `hooks` configuration provided in our example, which registers this script to run before any `Bash` tool usage.

This script parses the command the LLM intends to run and strictly blocks (Exit Code 2) known data exfiltration commands like `gh repo create` or `gh gist create`, while allowing safe querying commands to proceed.

## Important Considerations

- **Docker/Watchman**: Tools like Docker and Watchman are incompatible with the sandbox. You may need to add them to `excludedCommands` to run them outside the sandbox, but do so carefully.
- **Network Filtering**: The network sandbox restricts connections by domain, but does not inspect traffic. Be mindful of domain fronting or overly broad allowlists (e.g., allowing all of `github.com` could still permit data exfiltration to an attacker-controlled repository).

## References

- [Official Claude Code Sandboxing Documentation](https://code.claude.com/docs/en/sandboxing)
- [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
