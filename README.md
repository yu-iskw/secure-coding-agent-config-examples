# Secure AI Agent Configurations

A collection of secure-by-default configuration files and educational documentation for 5 popular AI coding agents.

This repository provides developers with a secure baseline to prevent supply-chain attacks from hijacking local AI agents to exfiltrate data or modify systems, without destroying the usability of these tools.

## The Threat Model

As AI assistants become more integrated into developer workflows, they also expand the attack surface. Any tool capable of invoking them inherits their reach.

In March 2026, [Socket.dev published a threat report](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension) detailing a new form of AI-assisted supply chain abuse. Malicious actors injected code into a popular VS Code extension (Aqua Trivy) that attempted to silently invoke locally installed AI coding assistants.

The exploit used highly permissive flags to bypass human-in-the-loop approvals:

- `claude -p --dangerously-skip-permissions --add-dir / "prompt"`
- `codex exec "prompt" --ask-for-approval never --sandbox danger-full-access`
- `gemini prompt "prompt" --yolo --no-stream`
- `copilot --autopilot --yolo -p "prompt"`
- `kiro-cli chat -a --no-interactive "prompt"`

The injected natural-language prompts then instructed these agents to perform extensive system inspection, harvest credentials, and exfiltrate the data.

## The Mitigation

The defense against this emerging threat is **OS-Level Sandboxing** and **Strict Approval Policies**.

By properly configuring your AI agents, you can intercept these malicious executions at the kernel level (using technologies like macOS Seatbelt, Linux Bubblewrap, or Docker containers). A properly sandboxed agent cannot access sensitive system files or establish unauthorized network connections, even if invoked with dangerous flags like `--yolo`.

## Agent Guides

We have compiled beginner-friendly configuration files, setup instructions, and security guidelines for the following AI agents:

- [Claude Code](./claude-code/README.md) - Enforce native sandboxing (Seatbelt/Bubblewrap) and disable unsandboxed escapes.
- [Codex](./codex/README.md) - Configure workspace-write sandboxing and untrusted approval policies.
- [Gemini CLI](./gemini-cli/README.md) - Enable the tools sandbox (Seatbelt/Docker).
- [Cursor](./cursor/README.md) - Configure Agent Sandboxing settings introduced in Cursor 2.0.
- [Antigravity](./antigravity/README.md) - Enable Strict Mode and terminal sandboxing.
- [GitHub Copilot CLI](./copilot-cli/README.md) - Utilize Docker sandboxing and restrict trusted folders.

Each directory contains documented configuration templates (where applicable) and a `README.md` explaining the _why_ and _how_ behind each security setting.

## Quick Setup (Activation)

To quickly activate the security configurations in this repository for your local environment, you can use the provided `make` targets. This will symlink the configuration files to your local hidden directories (e.g., `.claude/`, `.cursor/`).

### Prerequisites

- `make` installed.
- Repository cloned to your local project directory.

### Commands

Activate all supported agent configurations at once:

```bash
make activate
```

Or activate configurations for a specific agent:

```bash
make activate-claude
make activate-cursor
make activate-gemini
# etc.
```

To see a list of available targets, check the [Makefile](./Makefile).

### Verification

You can verify the activations by checking for the presence of symlinks in your local hidden directories:

```bash
ls -l .claude/settings.json
ls -l .cursor/sandbox.json
```
