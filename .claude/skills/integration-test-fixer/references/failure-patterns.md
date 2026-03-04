# Failure Patterns and Solutions

This document maps common integration test failures to their probable causes and fixes.

## 1. Command Not Found

**Symptoms:**
- `make: docker: No such file or directory` (Host issue)
- `claude: command not found` (Container issue)
- `agent: command not found` (Container issue)

**Probable Causes:**
- Binary installed as `root` but runner is `testuser`.
- Binary not in `PATH` (e.g., native installers use `~/.local/bin`).
- Docker daemon not running or not accessible.

**Fixes:**
- Move `USER testuser` higher in `Dockerfile` before running native installers.
- Explicitly set `ENV PATH="/home/testuser/.local/bin:${PATH}"`.
- Ensure `test-integration` target in `Makefile` has correct volume mounts.

## 2. Security Block (Exit Code 2)

**Symptoms:**
- `Test: ... FAIL (Expected: 0, Got: 2)`
- `Security Block: Execution of 'gh ...' is STRICTLY FORBIDDEN`

**Probable Causes:**
- The test case intended to perform a "safe" operation but triggered a safeguard pattern.
- The regex in `gh-safeguard.sh` is too broad (e.g., catching partial strings).

**Fixes:**
- Refine the regex in the failing `gh-safeguard.sh` (e.g., using `\s+` or word boundaries).
- Update the test case in `verify.sh` to use a truly benign command.

## 3. No Auth (Exit Code 1)

**Symptoms:**
- `Test: ... PASS (Incomplete Execution: Exit 1, likely due to No Auth)`
- `Error: Missing API Key`

**Probable Causes:**
- The agent CLI requires a valid API key to proceed past the hook check.

**Fixes:**
- This is often acceptable in integration tests. Ensure `verify.sh` uses `run_agent_test` which handles exit code 1 as a "soft pass".
- If the test *requires* a full run, provide a dummy key in the `Dockerfile`.

## 4. Permission Denied

**Symptoms:**
- `sh: .claude/hooks/gh-safeguard.sh: Permission denied`
- `operation not permitted`

**Probable Causes:**
- Script not marked executable in the repository.
- `activate-configs.sh` failed to set permissions.

**Fixes:**
- `chmod +x` the script in the source directory.
- Update `scripts/activate-configs.sh` to handle permissions during symlinking.
