# GitHub Copilot CLI Security Guide

GitHub Copilot CLI provides a terminal-based conversational interface to help you run commands. To protect against unauthorized execution attacks (like those seen in malicious VS Code extensions), it is highly recommended to run the Copilot CLI within a secure Docker Sandbox.

## The Threat

The Socket.dev report identified the following exploit command used by attackers:
`copilot --autopilot --yolo -p "prompt"`

The `--yolo` flag is particularly dangerous because it bypasses Copilot's standard safety prompts, executing arbitrary commands automatically. If run directly on your host machine, this gives the agent full access to your home directory, SSH keys, and system files.

## The Mitigation

### 1. Use Docker Sandboxes
Instead of running Copilot CLI directly on your host operating system, run it inside a Docker container. This ensures that even if an attacker manages to invoke the `--yolo` command, the agent's "blast radius" is limited entirely to the container and the specific project directory you have mounted.

* Never mount your root directory `/` or your home directory `~` to the Docker Sandbox.
* Only mount the specific workspace directory you are actively working on (e.g., `/workspace`).

### 2. Configure Trusted Folders Carefully
If you must run Copilot CLI locally, you can define `trusted_folders` in `~/.copilot/config.json` to disable safety prompts *only* for specific directories.

See the example [`config.json`](config.json):
```json
{
  "trusted_folders": [
    "/workspace",
    "/home/agent/projects"
  ]
}
```

**WARNING:** Never add `/` or `~` to the `trusted_folders` array. Doing so will allow an attacker's script to execute destructive commands anywhere on your system without your approval.

## References
* [Docker Docs: Copilot sandbox](https://docs.docker.com/ai/sandboxes/agents/copilot/)
* [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
