# Antigravity Security Guide

Google Antigravity provides terminal sandboxing for its AI Agent using kernel-level isolation (Apple's Seatbelt mechanism on macOS). When enabled, commands run in a restricted environment with limited file system and network access, protecting your system from unintended modifications.

## The Threat

A compromised environment or malicious script could attempt to silently invoke AI agents with dangerous permissions (like the Socket.dev report discovering the `--yolo` exploit in an Aqua Trivy extension). Unchecked AI agents could then explore your filesystem, modify system files, or exfiltrate credentials over the internet.

## The Solution

By configuring Antigravity's settings, you define strict boundaries that OS-level controls enforce. This is especially important for blocking automated, silent execution of arbitrary destructive commands.

To secure your project, Antigravity supports a project-level configuration file.

### How to Configure Terminal Sandboxing and Permissions

To securely configure the Antigravity Agent, copy the provided `config.json` file into your project:

1. Create a directory named `.antigravity` in the root of your project.
2. Copy the [`config.json`](config.json) file from this repository into that directory (e.g., `your-project/.antigravity/config.json`).

This configuration file implements several key security measures:

* **Strict Sandbox**: `sandbox.enabled: true` ensures the agent operates within defined limits.
* **Granular Permissions**:
  * `permissions.fileWrite: "prompt"` ensures the agent cannot silently modify or delete files without your explicit approval.
  * `permissions.networkAccess: "localhost-only"` blocks the agent from sending your data to external servers or downloading untrusted code.
  * `permissions.systemCommands: "blocked"` prevents the execution of arbitrary system-level commands.
* **Protected Paths**: The `protectedPaths` array explicitly denies access to sensitive locations like `.git`, `.env`, and credential files, preventing accidental or malicious modification.
* **Audit Logging**: `audit.enabled: true` and `audit.backupBeforeChanges: true` ensure that all actions are logged and backups are kept before any modifications occur.

### Global UI Settings (Optional)

In addition to the project-level `.antigravity/config.json`, you can also enforce global protection:

1. Open **Antigravity User Settings**.
2. Toggle **Enable Terminal Sandboxing** to **On** (enforces macOS Seatbelt).
3. Set the **Sandbox Allow Network** toggle to **Off**.

### Strict Mode Alternative

If you operate in highly sensitive environments, you can enforce maximum protection:

* Toggle **Strict Mode** in Antigravity User Settings.
   * *What this does:* When strict mode is enabled, sandboxing is automatically activated with network access denied. This ensures maximum protection when operating in a strict environment, overriding any individual sandbox toggles.

### Handling Sandbox Violations

If an agent command legitimately requires network access or file system access outside the sandbox, you can configure it via the **Request Review** mode. This ensures that a human is in the loop before any potentially dangerous action occurs.

## References
* [Official Google Antigravity Sandboxing Documentation](https://antigravity.google/docs/sandbox-mode)
* [Socket.dev Threat Report on Unauthorized AI Agent Execution](https://socket.dev/blog/unauthorized-ai-agent-execution-code-published-to-openvsx-in-aqua-trivy-vs-code-extension)
