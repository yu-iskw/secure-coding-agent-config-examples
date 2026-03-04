---
name: integration-test-fixer
description: Automatically run and fix integration tests for coding agent configurations.
---

# Integration Test Fixer

This skill automates the process of running the container-based integration tests, analyzing failures, and proposing/applying fixes.

## Purpose

To ensure that coding agent security configurations (hooks, sandboxes, etc.) remain valid and functional across all supported agents (Claude, Gemini, Cursor, Codex, Copilot).

## Instructions

### 1. Run the Verification Script

Execute the helper script to run the tests and get a structured report:

```bash
./.claude/skills/integration-test-fixer/scripts/verify-and-fix.sh
```

### 2. Analyze the Report

- If the script returns success, the tests are passing.
- If it fails, examine the JSON output or the console log to identify the failing test case.
- Cross-reference the failure with [references/failure-patterns.md](references/failure-patterns.md).

### 3. Apply Fixes

- **Path Issues**: Check `integration_tests/Dockerfile` or `scripts/activate-configs.sh`.
- **Hook Logic**: Check the respective `gh-safeguard.sh` or agent-specific hook script.
- **Dependency Issues**: Ensure the `Dockerfile` has all necessary libraries (e.g., `libnss3` for Cursor).

### 4. Verify

Re-run the verification script after applying changes to ensure the regression is resolved.

## References

- [Failure Patterns](references/failure-patterns.md)
- [Integration Tests Dockerfile](../../../integration_tests/Dockerfile)
- [Test Runner](../../../integration_tests/verify.sh)
