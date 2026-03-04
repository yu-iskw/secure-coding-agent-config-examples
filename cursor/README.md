# Cursor Security Guide

Cursor 2.0 introduced Agent Sandboxing on macOS, utilizing Apple's kernel-level Seatbelt primitive to securely isolate terminal commands executed by the AI agent. This guide explains how to properly configure these settings to protect your machine against unauthorized execution attacks.

## The Threat

A malicious VS Code or Cursor extension could attempt to silently invoke AI agents with dangerous permissions (like the Socket.dev report discovering the `--yolo` exploit in an Aqua Trivy extension). Unchecked AI agents could then explore your filesystem, modify system files, or exfiltrate credentials over the internet.

## The Solution

By enabling Agent Sandboxing, Cursor automatically restricts the agent's actions without requiring manual approval for every benign command.

### How to Configure Agent Sandboxing

To securely configure the Cursor Agent, follow these steps:

1. Open **Cursor Settings**.
2. Navigate to the **Agent** tab (under Features) -> **Auto-Run**.
3. Ensure **Auto-Run Mode** is set to **Run in Sandbox**.
   * *What this does:* It enforces strong, OS-level sandboxing (macOS Seatbelt or Linux Landlock). The agent can only read/write to your open workspace and `/tmp`. It cannot write to other directories or access `cursorignore`'d files.
4. Set the **Auto-run network access** toggle to **sandbox.json Only**.
   * *What this does:* When set to this mode, the agent cannot access the network except for domains explicitly allowed in your `sandbox.json` file. This prevents the agent from exfiltrating data to attacker-controlled servers.
5. Set **External-File Protection** to **On**.
   * *What this does:* Prevents the agent from creating or modifying files outside of the workspace automatically.

### Configuring Network Access (`sandbox.json`)

Cursor 2.5 introduced granular network access controls via `sandbox.json`. Place the provided [`sandbox.json`](sandbox.json) in your project's `.cursor/` directory (`.cursor/sandbox.json`) or globally in `~/.cursor/sandbox.json`.

Key security settings include:

* **`"networkPolicy": { "default": "deny" }`**: Explicitly denies all outbound network traffic from the sandbox unless it matches a pattern in the allowlist.
* **`"allow": [...]`**: A strict allowlist of necessary domains, such as package registries (npm, PyPI, Go, Crates, etc.) and GitHub. Only these domains are reachable.
* **`"deny": [...]`**: You can explicitly block access to internal corporate services or specific IPs to prevent Server-Side Request Forgery (SSRF) attacks or internal reconnaissance.

### Strict Mode Alternative

If you do not want to use the sandbox feature, or if you are using a model that doesn't fully support sandboxing yet, you can configure Cursor to fall back on strict manual approvals:

* Under Cursor Agent settings, select **Ask Every Time**.
   * *What this does:* Cursor will pause and ask for your explicit manual approval before executing *any* command in the terminal.

## References
* [Cursor 2.0 Agent Sandboxing Announcement](https://forum.cursor.com/t/agent-sandboxing-available-in-cursor-2-0/139449)
* [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
