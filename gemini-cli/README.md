# Gemini CLI Security Guide

The Gemini CLI uses sandboxing to isolate potentially dangerous operations (such as shell commands or file modifications) from your host system. This guide covers how to enable these protections against unauthorized execution by malicious scripts or extensions.

## The Threat

Attackers can use malicious VS Code extensions or scripts to silently invoke the Gemini CLI and exfiltrate data. The Socket.dev report identified the following exploit command:
`gemini prompt "prompt" --yolo --no-stream`

This command instructs the agent to execute without human-in-the-loop approval, potentially reading sensitive data across the entire system and sending it back to an attacker's server.

## The Solution

By configuring the Gemini CLI's sandboxing, you define strict boundaries that are enforced at the OS level (Seatbelt on macOS) or via containerization (Docker/Podman).

### Recommended Configuration (`settings.json`)

Copy the provided [`settings.json`](settings.json) to your configuration file path.

Key security settings include:

* **`"sandbox": true`**: Activates the sandboxing runtime. All operations performed by the Gemini CLI will be constrained by the sandbox, preventing unrestricted writes outside the project directory.

Alternatively, you can enable sandboxing via environment variables (`GEMINI_SANDBOX=true` or `GEMINI_SANDBOX=docker`) or with the `-s` command flag.

## Sandboxing Modes

Depending on your platform and setup, the Gemini CLI uses different sandboxing methods:

* **macOS Seatbelt**: The default profile (`permissive-open`) restricts writes outside the project directory but allows most other operations.
* **Docker/Podman**: Cross-platform sandboxing with complete process isolation. Use `GEMINI_SANDBOX=docker` if you prefer container-based isolation.

Even when sandboxing is enabled, GUI applications may not work properly, and network traffic may still be allowed depending on the sandbox profile used.

## References
* [Official Gemini CLI Sandboxing Documentation](https://geminicli.com/docs/cli/sandbox/)
* [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
