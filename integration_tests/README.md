# Integration Tests

This directory contains a container-based integration test suite designed to securely verify the repository's AI agent configurations.

## Overview

The integration tests ensure that:

1.  **Security Hooks** (like `gh-safeguard.sh`) correctly block exfiltration commands.
2.  **Agent Configurations** are valid and correctly register these hooks.
3.  **Agent CLIs** (Claude, Gemini, Cursor, Codex) respect these configurations in a live (but isolated) environment.

## Testing Strategy

The test runner (`verify.sh`) operates in three distinct phases:

### Phase 1: Direct Hook Verification

This phase unit tests the `gh-safeguard.sh` script directly. It passes dummy JSON payloads (simulating different agent schemas) to the hook and asserts that it returns Exit Code 2 for blocked commands and Exit Code 0 for safe ones.

### Phase 2: Configuration Verification

This phase uses `jq` and `grep` to inspect the symlinked configuration files inside the container. It verifies that each agent is explicitly configured to use the security hooks or sandboxing features provided by this repository.

### Phase 3: Agent CLI Probes

This phase attempts to run the actual agent CLI commands (e.g., `claude -p`, `gemini prompt`).

- **Security Block**: If the hook correctly intercepts the command, the agent returns Exit Code 2 (PASS).
- **Authentication Failure**: Since the tests run with dummy API keys, they may return Exit Code 1. We treat this as a "soft pass" (Incomplete Execution), as it confirms the agent CLI is installed and attempted to run the configured hook before failing on auth.

## Running Tests

### Prerequisites

- Docker installed and running.
- `make` installed.

### Command

```bash
make test-integration
```

## Maintenance

### Dockerfile

The `Dockerfile` builds a `node:22-slim` image and installs all supported agent CLIs.

- It uses native installers where possible (Claude Code, Cursor).
- It creates a non-root `testuser` to simulate a real developer environment.
- It includes all necessary system libraries for Electron-based agents (like Cursor).

### Adding New Tests

To add a new test case:

1.  Open `verify.sh`.
2.  Add a new `run_test` call in Phase 1 or a `run_agent_test` call in Phase 3.
3.  Ensure the `expected_exit_code` matches the behavior you want to verify.

## Automated Maintenance

We use the **[Integration Test Fixer](../.claude/skills/integration-test-fixer/SKILL.md)** agent skill to automate the "test-analyze-fix" loop. This skill can identify common failure patterns (like missing dependencies or path issues) and propose fixes.
