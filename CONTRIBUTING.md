# Contributing to Secure AI Agent Configurations

Thank you for your interest in improving the security of AI coding agents! This document provides instructions for developers and maintainers on how to contribute to this repository.

## Adding New Agent Configurations

If you want to add support for a new coding agent, please follow these steps:

1. **Analyze**: Understand the agent's sandboxing and security capabilities.
2. **Configure**: Create a directory for the agent (e.g., `my-agent/`) and include a secure-by-default `settings.json`, `config.json`, or similar.
3. **Hooks**: If the agent supports pre-execution hooks, implement a `gh-safeguard.sh` or equivalent script to prevent data exfiltration.
4. **Document**: Add a `README.md` and `README.ja.md` in the agent's directory explaining the security settings.
5. **Test**: Add the agent CLI to the `integration_tests/Dockerfile` and create test probes in `integration_tests/verify.sh`.

## Continuous Verification

This repository includes a container-based integration test suite to verify that the security configurations are correctly parsed by the latest agent CLIs and that the security hooks (like `gh-safeguard.sh`) effectively block prohibited actions in an isolated environment.

For more details, see the [Integration Tests](./integration_tests/README.md) documentation.

### Running Tests

To run the full integration test suite locally:

```bash
make test-integration
```

This will build a Docker image with all supported agent CLIs installed and run a series of "exfiltration probes" to confirm the safeguards are working as intended.

## Agent Skills

We provide specialized Agent Skills to automate the maintenance and verification of these configurations.

- **[Integration Test Fixer](./.claude/skills/integration-test-fixer/SKILL.md)**: Automatically runs the integration tests, analyzes failures using common patterns, and proposes or applies fixes to the configurations or environment.

## Linting & Formatting

To ensure consistent code quality and security, please run the following commands before submitting a pull request:

- **Check for issues**: `make lint`
- **Auto-format code**: `make format`

We use [Trunk](https://trunk.io/) to manage our linters and formatters (including Hadolint for Dockerfiles and ShellCheck for scripts).
