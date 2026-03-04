# Claude Code Project Configuration

## Available Skills

When asked to update agent settings, refresh coding agent configs, or check for new sandbox best practices, use the `update-agent-configs` skill.

This skill instructs Claude Code to periodically research the latest security best practices, documentation, and vulnerability reports for AI coding agents and update their respective local configuration files and markdown guides in this repository.

To invoke the skill, Claude Code will read `.claude/skills/update-agent-configs/SKILL.md` and follow its instructions.
